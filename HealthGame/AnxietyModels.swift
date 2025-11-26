import Foundation
import SwiftUI

enum ConfidenceLevel: String {
    case high
    case medium
    case low
}

enum SignalQuality: String {
    case good
    case ok
    case poor
}

struct Baseline {
    var mean: Double
    var sd: Double
    var lastUpdated: Date
}

struct BaselineProfile {
    var hr: Baseline
    var hrv: Baseline
    var rr: Baseline
    var eda: Baseline
    var temp: Baseline
}

struct PhysioData: Identifiable {
    let id = UUID()
    var hr: Double
    var hrv: Double
    var rr: Double
    var edaPeaksPerMin: Double
    var skinTempDelta: Double
    var motionScore: Double
    var isExercising: Bool
    var signalQuality: SignalQuality
    var timestamp: Date
}

enum CyclePhase: String, CaseIterable {
    case none = "No Data"
    case follicular = "Follicular"
    case ovulatory = "Ovulatory"
    case luteal = "Luteal"
    case pms = "PMS"
}

struct LifestyleData {
    var sleepStart: Date
    var wakeTime: Date
    var sleepDebtHours: Double
    var sleepEfficiency: Double
    var bedtimeShiftMinutes: Double

    var caffeineMgAfter2pm: Double
    var nicotine: Bool
    var alcoholUnitsAfter8pm: Int

    var activityMinutes: Double
    var vigorousMinutes: Double
    var workloadHours: Double
    var isExamDay: Bool

    var selfCareMinutes: Double
    var hasCycleData: Bool
    var cyclePhase: CyclePhase

    var post11pmScreenMinutes: Double
    var daytimeScreenHours: Double

    var skippedMeals: Int
    var sugaryItems: Int
    var waterGlasses: Int
}

struct CheckinData {
    var gad2Score: Int
    var gadUpdated: Date
    var mood: Int
    var moodUpdated: Date
    var anxietyMoments: [AnxietyMoment]
}

struct AnxietyMoment: Identifiable {
    let id = UUID()
    var note: String
    var timestamp: Date
    var intensity: Double
}

struct AnxietyScore {
    var aps: Double
    var lrs: Double
    var cs: Double
    var stateEstimate: Double
    var finalScore: Double
    var confidence: ConfidenceLevel
    var alpha: Double
    var checkinWeight: Double
}

struct Contributor: Identifiable {
    let id = UUID()
    var name: String
    var category: ContributorCategory
    var impact: Double
    var trend: ContributorTrend
}

enum ContributorCategory: String {
    case physiology
    case lifestyle
    case checkin
}

enum ContributorTrend: String {
    case up
    case down
    case stable
}

struct TrendPoint: Identifiable {
    let id = UUID()
    var label: String
    var value: Double
}

struct DailyScore: Identifiable {
    let id = UUID()
    var date: Date
    var score: Double
    var topFactor: String
    var physiology: Double
    var lifestyle: Double
    var checkin: Double
}

struct Intervention: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var duration: String
    var minutes: Int
    var rating: Double
    var icon: String
    var category: String
    var effect: String
    var quickRelief: Bool
}
