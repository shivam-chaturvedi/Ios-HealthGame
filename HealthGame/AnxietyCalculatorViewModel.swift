import Foundation
import SwiftUI

@MainActor
final class AnxietyCalculatorViewModel: ObservableObject {
    @Published var baseline: BaselineProfile
    @Published var physio: PhysioData
    @Published var lifestyle: LifestyleData
    @Published var checkin: CheckinData
    @Published var score: AnxietyScore
    @Published var contributors: [Contributor]
    @Published var trend: [TrendPoint]
    @Published var weekly: [DailyScore]
    @Published var interventions: [Intervention]
    @Published var aiAdaptiveMode = true
    @Published var calibrationStart: Date
    @Published var restWindows: [Date]

    init() {
        let now = Date()
        let calendar = Calendar.current
        self.baseline = BaselineProfile(
            hr: Baseline(mean: 62, sd: 6, lastUpdated: now.addingTimeInterval(-3600)),
            hrv: Baseline(mean: 55, sd: 12, lastUpdated: now.addingTimeInterval(-3600)),
            rr: Baseline(mean: 14, sd: 2, lastUpdated: now.addingTimeInterval(-3600)),
            eda: Baseline(mean: 1.2, sd: 0.6, lastUpdated: now.addingTimeInterval(-3600)),
            temp: Baseline(mean: 0, sd: 0.6, lastUpdated: now.addingTimeInterval(-3600))
        )

        self.physio = PhysioData(
            hr: 74,
            hrv: 48,
            rr: 15,
            edaPeaksPerMin: 2.0,
            skinTempDelta: -0.6,
            motionScore: 0.2,
            isExercising: false,
            signalQuality: .good,
            timestamp: now
        )

        self.lifestyle = LifestyleData(
            sleepStart: calendar.date(from: DateComponents(hour: 23, minute: 30)) ?? now,
            wakeTime: calendar.date(from: DateComponents(hour: 7, minute: 0)) ?? now,
            sleepDebtHours: 1,
            sleepEfficiency: 85,
            bedtimeShiftMinutes: 60,
            caffeineMgAfter2pm: 120,
            nicotine: false,
            alcoholUnitsAfter8pm: 1,
            activityMinutes: 35,
            vigorousMinutes: 20,
            workloadHours: 7,
            isExamDay: false,
            selfCareMinutes: 18,
            hasCycleData: true,
            cyclePhase: .luteal,
            post11pmScreenMinutes: 40,
            daytimeScreenHours: 6.5,
            skippedMeals: 0,
            sugaryItems: 1,
            waterGlasses: 6
        )

        self.checkin = CheckinData(
            gad2Score: 3,
            gadUpdated: now.addingTimeInterval(-2 * 3600),
            mood: 2,
            moodUpdated: now.addingTimeInterval(-1 * 3600),
            anxietyMoments: [
                AnxietyMoment(note: "Felt anxious before meeting", timestamp: now.addingTimeInterval(-7200), intensity: 0.6)
            ]
        )

        self.trend = Self.makeTrend()
        self.weekly = Self.makeWeekly()
        self.interventions = Self.makeInterventions()
        self.contributors = []
        self.calibrationStart = now.addingTimeInterval(-1 * 24 * 3600)
        self.restWindows = [now.addingTimeInterval(-1800)]

        let initialScore = AnxietyScore(aps: 0, lrs: 0, cs: 0, stateEstimate: 0, finalScore: 0, confidence: .medium, alpha: 0.5, checkinWeight: 0.5)
        self.score = initialScore
        recompute()
    }

    var calibrationEnd: Date {
        calibrationStart.addingTimeInterval(3 * 24 * 3600)
    }

    func recompute() {
        let lrsScore = computeLifestyleScore()
        let apsScore = computeAPS()
        let checkinResult = computeCheckinScore()
        let alphaValue = computeAlpha()
        let stateEstimate = alphaValue * apsScore + (1 - alphaValue) * lrsScore
        let finalScore = checkinResult.weight * checkinResult.score + (1 - checkinResult.weight) * stateEstimate
        let confidenceLevel = computeConfidence(checkinWeight: checkinResult.weight)

        self.score = AnxietyScore(
            aps: apsScore,
            lrs: lrsScore,
            cs: checkinResult.score,
            stateEstimate: stateEstimate,
            finalScore: finalScore,
            confidence: confidenceLevel,
            alpha: alphaValue,
            checkinWeight: checkinResult.weight
        )

        self.contributors = buildContributors(lrs: lrsScore, aps: apsScore)
    }

    func addAnxietyMoment(note: String, intensity: Double) {
        checkin.anxietyMoments.insert(.init(note: note, timestamp: Date(), intensity: intensity), at: 0)
        recompute()
    }

    func updateCheckin(gad2: Int, mood: Int) {
        checkin.gad2Score = gad2
        checkin.gadUpdated = Date()
        checkin.mood = mood
        checkin.moodUpdated = Date()
        recompute()
    }

    func updateLifestyle(_ updates: (inout LifestyleData) -> Void) {
        updates(&lifestyle)
        recompute()
    }

    func simulateLiveTick() {
        physio.timestamp = Date()
        physio.hr += Double.random(in: -2...3)
        physio.hrv += Double.random(in: -4...4)
        physio.rr += Double.random(in: -0.4...0.6)
        physio.edaPeaksPerMin = max(0, physio.edaPeaksPerMin + Double.random(in: -0.5...0.8))
        physio.skinTempDelta += Double.random(in: -0.1...0.1)
        physio.motionScore = min(1, max(0, physio.motionScore + Double.random(in: -0.1...0.15)))
        if physio.motionScore < 0.2 {
            recordRestWindow()
        }
        recompute()
    }
}

// MARK: - Scoring
private extension AnxietyCalculatorViewModel {
    func computeCheckinScore() -> (score: Double, weight: Double) {
        let gadScaled = (Double(checkin.gad2Score) / 6.0) * 100
        let moodScaled = (Double(checkin.mood) / 4.0) * 100

        let mostRecentDate = max(checkin.gadUpdated, checkin.moodUpdated)
        let mostRecentScore: Double = checkin.moodUpdated > checkin.gadUpdated ? moodScaled : gadScaled
        let elapsed = Date().timeIntervalSince(mostRecentDate)

        let eightHours: Double = 8 * 3600
        let weight = exp(-elapsed / eightHours)

        return (mostRecentScore, min(1, max(0, weight)))
    }

    func computeLifestyleScore() -> Double {
        let sleep = sleepRisk()
        let stimulants = stimulantRisk()
        let activity = activityRisk()
        let context = contextRisk()
        let selfCare = selfCareRisk()
        let cycle = cycleRisk()
        let screen = screenRisk()
        let diet = dietRisk()

        // Lifestyle Weights from spec
        let lrs =
        0.30 * sleep +
        0.20 * stimulants +
        0.10 * activity +
        0.15 * context +
        0.05 * selfCare +
        0.05 * cycle +
        0.10 * screen +
        0.05 * diet

        return lrs
    }

    func computeAPS() -> Double {
        let hrRisk = heartRateRisk()
        let hrvRisk = hrvRiskScore()
        let rrRisk = rrRiskScore()
        let edaRisk = edaRiskScore()
        let tempRisk = tempRiskScore()
        let motionRisk = motionRiskScore()

        let aps =
        0.20 * hrRisk +
        0.20 * hrvRisk +
        0.15 * rrRisk +
        0.20 * edaRisk +
        0.10 * tempRisk +
        0.15 * motionRisk

        let cleanSignals = [hrRisk, hrvRisk, rrRisk, edaRisk, tempRisk, motionRisk].filter { $0 > 0 }
        let qualityScale = cleanSignals.count < 2 ? 0.3 : 1.0

        return aps * qualityScale
    }

    func computeAlpha() -> Double {
        if physio.isExercising || physio.signalQuality == .poor {
            return 0
        }
        return 0.5
    }

    func computeConfidence(checkinWeight: Double) -> ConfidenceLevel {
        let sensorQuality: Double
        switch physio.signalQuality {
        case .good: sensorQuality = 0.9
        case .ok: sensorQuality = 0.65
        case .poor: sensorQuality = 0.35
        }

        let coverage = (checkinWeight > 0.6 ? 0.4 : 0.25) + (physio.isExercising ? -0.1 : 0)
        let score = max(0, min(1, 0.5 * sensorQuality + coverage))

        if score > 0.75 { return .high }
        if score > 0.45 { return .medium }
        return .low
    }
}

// MARK: - Baseline maintenance
private extension AnxietyCalculatorViewModel {
    func recordRestWindow() {
        if let last = restWindows.last, Date().timeIntervalSince(last) < 120 {
            return
        }
        restWindows.append(Date())
        updateBaseline(physio.hr, keyPath: \.hr)
        updateBaseline(physio.hrv, keyPath: \.hrv)
        updateBaseline(physio.rr, keyPath: \.rr)
        updateBaseline(physio.edaPeaksPerMin, keyPath: \.eda)
        updateBaseline(physio.skinTempDelta, keyPath: \.temp)
    }

    func updateBaseline(_ value: Double, keyPath: WritableKeyPath<BaselineProfile, Baseline>) {
        let halfLife: Double = 14 * 24 * 3600
        let lambda = log(2) / halfLife
        var target = baseline[keyPath: keyPath]
        let elapsed = Date().timeIntervalSince(target.lastUpdated)
        let decay = exp(-lambda * elapsed)

        let newMean = target.mean * decay + value * (1 - decay)
        let deviation = abs(value - target.mean)
        let newSD = target.sd * decay + deviation * (1 - decay)

        target.mean = newMean
        target.sd = max(0.1, newSD)
        target.lastUpdated = Date()
        baseline[keyPath: keyPath] = target
    }
}

// MARK: - Lifestyle risk mapping (exact mappings)
private extension AnxietyCalculatorViewModel {
    func sleepRisk() -> Double {
        let debt = lifestyle.sleepDebtHours
        let base: Double
        if debt <= 0 { base = 20 }
        else if debt <= 1 { base = 40 }
        else if debt <= 2 { base = 60 }
        else if debt <= 3 { base = 80 }
        else { base = 95 }

        var total = base
        if lifestyle.sleepEfficiency < 80 { total += 10 }
        if lifestyle.bedtimeShiftMinutes > 90 { total += 5 }
        return min(100, total)
    }

    func stimulantRisk() -> Double {
        let caffeine = lifestyle.caffeineMgAfter2pm
        let caffeineScore: Double
        if caffeine <= 0 { caffeineScore = 20 }
        else if caffeine <= 100 { caffeineScore = 40 }
        else if caffeine <= 200 { caffeineScore = 65 }
        else { caffeineScore = 85 }

        var risk = caffeineScore
        if lifestyle.nicotine { risk = max(risk, 80) }
        if lifestyle.alcoholUnitsAfter8pm > 0 {
            let alcoholAdd = Double(lifestyle.alcoholUnitsAfter8pm * 10)
            risk = min(95, risk + alcoholAdd)
        }
        return min(100, risk)
    }

    func activityRisk() -> Double {
        var risk = 50.0
        if lifestyle.activityMinutes <= 10 {
            risk += 10
        } else if lifestyle.activityMinutes <= 20 {
            risk += 0
        } else if lifestyle.activityMinutes <= 30 {
            risk -= 5
        } else if lifestyle.activityMinutes <= 60 {
            risk -= 15
        }
        if lifestyle.vigorousMinutes > 120 {
            risk += 5
        }
        return min(100, max(0, risk))
    }

    func contextRisk() -> Double {
        var risk = lifestyle.isExamDay ? 85 : 45
        if lifestyle.workloadHours > 8 {
            risk += 10
        }
        return min(100, risk)
    }

    func selfCareRisk() -> Double {
        var risk = 50.0
        switch lifestyle.selfCareMinutes {
        case ..<1:
            risk += 5
        case 0...10:
            risk += 0
        case 10...15:
            risk -= 5
        case 20...30:
            risk -= 10
        default:
            risk -= 15
        }
        return min(100, max(0, risk))
    }

    func cycleRisk() -> Double {
        if lifestyle.hasCycleData == false {
            return 50
        }
        switch lifestyle.cyclePhase {
        case .pms, .luteal:
            return 65
        case .follicular, .ovulatory:
            return 45
        case .none:
            return 50
        }
    }

    func screenRisk() -> Double {
        let minutes = lifestyle.post11pmScreenMinutes
        let lateUse: Double
        if minutes <= 0 { lateUse = 20 }
        else if minutes <= 30 { lateUse = 50 }
        else if minutes <= 60 { lateUse = 70 }
        else { lateUse = 85 }

        var risk = lateUse
        if lifestyle.daytimeScreenHours > 6 {
            let extraHours = lifestyle.daytimeScreenHours - 6
            risk += max(0, extraHours * 5)
        }
        return min(100, risk)
    }

    func dietRisk() -> Double {
        var risk = 30.0
        risk += Double(lifestyle.skippedMeals * 15)
        risk += Double(lifestyle.sugaryItems * 10)
        if lifestyle.waterGlasses < 5 {
            risk += 15
        } else if lifestyle.waterGlasses >= 8 {
            risk -= 5
        }
        return min(100, max(0, risk))
    }
}

// MARK: - Physiology risk mapping
private extension AnxietyCalculatorViewModel {
    func heartRateRisk() -> Double {
        if physio.isExercising { return 0 }
        let z = zScore(current: physio.hr, baseline: baseline.hr)
        if z >= 3 { return 95 }
        if z >= 2 { return 85 }
        if z >= 1.5 { return 70 }
        if z >= 1 { return 50 }
        return 40
    }

    func hrvRiskScore() -> Double {
        if physio.isExercising { return 0 }
        let z = zScore(current: physio.hrv, baseline: baseline.hrv)
        if z <= -3 { return 95 }
        if z <= -2 { return 85 }
        if z <= -1 { return 70 }
        if z > 0.5 { return 40 }
        return 50
    }

    func rrRiskScore() -> Double {
        if physio.isExercising { return 0 }
        let delta = physio.rr - baseline.rr.mean
        if delta >= 8 { return 100 }
        if delta >= 6 { return 90 }
        if delta >= 4 { return 80 }
        if delta >= 2 { return 65 }
        return 50
    }

    func edaRiskScore() -> Double {
        if physio.isExercising { return 0 }
        let delta = physio.edaPeaksPerMin - baseline.eda.mean
        if delta >= 4 { return 95 }
        if delta >= 2 { return 80 }
        if delta >= 1 { return 65 }
        return 50
    }

    func tempRiskScore() -> Double {
        if physio.isExercising { return 0 }
        let delta = physio.skinTempDelta - baseline.temp.mean
        if delta <= -3 { return 95 }
        if delta <= -2 { return 80 }
        if delta <= -1 { return 65 }
        if delta > 0.2 { return 40 }
        return 50
    }

    func motionRiskScore() -> Double {
        if physio.isExercising { return 0 }
        // Micro-movements / fidgeting risk mapping: 60–80 depending on intensity
        let fidget = min(1, max(0, physio.motionScore))
        return 60 + (20 * fidget)
    }

    func zScore(current: Double, baseline: Baseline) -> Double {
        guard baseline.sd > 0 else { return 0 }
        return (current - baseline.mean) / baseline.sd
    }
}

// MARK: - Contributors + helpers
private extension AnxietyCalculatorViewModel {
    func buildContributors(lrs: Double, aps: Double) -> [Contributor] {
        var list: [Contributor] = []

        let lifestylePairs: [(String, Double)] = [
            ("sleep", 0.30 * sleepRisk()),
            ("stimulants", 0.20 * stimulantRisk()),
            ("activity", 0.10 * activityRisk()),
            ("context", 0.15 * contextRisk()),
            ("self-care", 0.05 * selfCareRisk()),
            ("cycle", 0.05 * cycleRisk()),
            ("screen", 0.10 * screenRisk()),
            ("diet", 0.05 * dietRisk())
        ]

        let physiologyPairs: [(String, Double)] = [
            ("HR", 0.20 * heartRateRisk()),
            ("HRV", 0.20 * hrvRiskScore()),
            ("RR", 0.15 * rrRiskScore()),
            ("EDA", 0.20 * edaRiskScore()),
            ("Temp", 0.10 * tempRiskScore()),
            ("Motion", 0.15 * motionRiskScore())
        ]

        let lifestyleImpactTotal = lifestylePairs.reduce(0) { $0 + $1.1 }
        let physiologyImpactTotal = physiologyPairs.reduce(0) { $0 + $1.1 }

        let lifestyleTop = lifestylePairs.sorted { $0.1 > $1.1 }.prefix(2)
        let physiologyTop = physiologyPairs.sorted { $0.1 > $1.1 }.prefix(2)

        for pair in lifestyleTop {
            list.append(
                Contributor(
                    name: pair.0,
                    category: .lifestyle,
                    impact: percentContribution(part: pair.1, total: lrs),
                    trend: .up
                )
            )
        }

        for pair in physiologyTop {
            list.append(
                Contributor(
                    name: pair.0,
                    category: .physiology,
                    impact: percentContribution(part: pair.1, total: aps),
                    trend: pair.0 == "HRV" ? .down : .up
                )
            )
        }

        list.append(
            Contributor(
                name: "Check-in",
                category: .checkin,
                impact: percentContribution(part: score.cs, total: score.finalScore),
                trend: score.checkinWeight > 0.5 ? .stable : .down
            )
        )

        return list
    }

    func percentContribution(part: Double, total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (part / total) * 100
    }
}

// MARK: - Mock data
private extension AnxietyCalculatorViewModel {
    static func makeTrend() -> [TrendPoint] {
        [
            TrendPoint(label: "−11h", value: 48),
            TrendPoint(label: "−10h", value: 50),
            TrendPoint(label: "−9h", value: 52),
            TrendPoint(label: "−8h", value: 56),
            TrendPoint(label: "−7h", value: 58),
            TrendPoint(label: "−6h", value: 61),
            TrendPoint(label: "−5h", value: 59),
            TrendPoint(label: "−4h", value: 57),
            TrendPoint(label: "−3h", value: 55),
            TrendPoint(label: "−2h", value: 54),
            TrendPoint(label: "−1h", value: 53),
            TrendPoint(label: "now", value: 51)
        ]
    }

    static func makeWeekly() -> [DailyScore] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { offset in
            DailyScore(
                date: calendar.date(byAdding: .day, value: -offset, to: today) ?? today,
                score: Double.random(in: 42...68),
                topFactor: ["sleep", "screen", "stimulants", "activity"].randomElement() ?? "sleep",
                physiology: Double.random(in: 40...70),
                lifestyle: Double.random(in: 38...65),
                checkin: Double.random(in: 30...70)
            )
        }.sorted { $0.date < $1.date }
    }

    static func makeInterventions() -> [Intervention] {
        [
            Intervention(title: "4-7-8 Breathing", subtitle: "Inhale 4s, hold 7s, exhale 8s", duration: "5 min", minutes: 5, rating: 4.2, icon: "wind", category: "Breathwork", effect: "Calms sympathetic arousal", quickRelief: true),
            Intervention(title: "Box Breathing", subtitle: "Inhale, hold, exhale, hold — each 4s", duration: "4 min", minutes: 4, rating: 4.5, icon: "square", category: "Breathwork", effect: "Steady rhythm to reset", quickRelief: true),
            Intervention(title: "5-4-3-2-1 Grounding", subtitle: "Notice 5 senses to anchor", duration: "3 min", minutes: 3, rating: 4.0, icon: "hand.raised.fill", category: "Grounding", effect: "Interrupts racing thoughts", quickRelief: false),
            Intervention(title: "Short Walk", subtitle: "Brief outdoor reset", duration: "5 min", minutes: 5, rating: 4.3, icon: "figure.walk", category: "Movement", effect: "Reduce cortisol spike", quickRelief: false),
            Intervention(title: "Anxiety Dump", subtitle: "Write down everything on your mind", duration: "3 min", minutes: 3, rating: 3.8, icon: "pencil.and.outline", category: "Reflection", effect: "Label and diffuse", quickRelief: false),
            Intervention(title: "Calming Soundscape", subtitle: "Lo-fi or binaural beats", duration: "10 min", minutes: 10, rating: 3.9, icon: "music.quarternote.3", category: "Audio", effect: "Lower arousal through tempo", quickRelief: false),
            Intervention(title: "Pro Tip", subtitle: "Practice daily breathing reduces anxiety baseline", duration: "Tip", minutes: 1, rating: 4.6, icon: "star.circle.fill", category: "Tip", effect: "Consistent practice improves resilience", quickRelief: false)
        ]
    }
}
