import Foundation
import HealthKit
import SwiftUI
import Combine

final class PhysioLiveViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    enum Signal: String, CaseIterable {
        case hr = "HR"
        case hrv = "HRV"
        case rr = "RR"
        case eda = "EDA"
    }

    struct SamplePoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    struct MetricCard: Identifiable {
        enum Status {
            case normal
            case elevated
            case low
        }

        enum Trend {
            case up
            case down
            case stable
        }

        let id = UUID()
        let signal: Signal?
        let title: String
        let valueText: String
        let unit: String
        let icon: String
        let color: Color
        let baselineMean: String
        let baselineSD: String
        let status: Status
        let trend: Trend
        let numericValue: Double
    }

    struct PhysioBaseline {
        var mean: Double
        var sd: Double
    }

    @Published var authorizationGranted = false
    @Published var selectedSignal: Signal = .hr
    @Published var series: [Signal: [SamplePoint]] = [:]
    @Published var cards: [MetricCard] = []
    @Published var stateTitle = "At Rest"
    @Published var stateDetail = "Sensors active • Good signal quality"
    @Published var calibrationProgress: Double = 1.0
    @Published var calibrationText = "Complete"
    @Published var signalQuality: SignalQuality = .good
    let minutesWindow: Double = 30

    private let healthStore = HKHealthStore()

    private var baselines: [Signal: PhysioBaseline] = [:]
    private var skinTempValues: [Double] = []
    private var motionValue: Double?

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types = HealthTypes.allTypes.union(HealthTypes.optionalTypes)
        healthStore.requestAuthorization(toShare: nil, read: types) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.authorizationGranted = success
                if success {
                    self?.refreshAll()
                }
            }
        }
    }

    func refreshAll() {
        fetchRestState()
        fetchSignal(.hr, unit: HKUnit(from: "count/min"))
        fetchSignal(.hrv, unit: HKUnit.secondUnit(with: .milli))
        fetchSignal(.rr, unit: HKUnit.count().unitDivided(by: HKUnit.minute()))
        if #available(iOS 17.0, *) {
            fetchSignal(.eda, unit: HKUnit.siemenUnit(with: .milli))
        }
        fetchMotionFidgeting()
        fetchSkinTemperature()
    }
}

// MARK: - Fetching
private extension PhysioLiveViewModel {
    func fetchSignal(_ signal: Signal, unit: HKUnit) {
        guard let type = quantityType(for: signal) else { return }

        let now = Date()
        let startDate = now.addingTimeInterval(-minutesWindow * 60)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)

        // Time series for live chart
        let seriesQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) { [weak self] _, samples, _ in
            guard let self else { return }
            let points = (samples as? [HKQuantitySample])?
                .map { SamplePoint(date: $0.endDate, value: $0.quantity.doubleValue(for: unit)) } ?? []
            DispatchQueue.main.async {
                self.series[signal] = points
                self.updateCards()
            }
        }
        healthStore.execute(seriesQuery)

        // Baseline (last 24h mean + SD)
        let baselineStart = now.addingTimeInterval(-24 * 3600)
        let baselinePredicate = HKQuery.predicateForSamples(withStart: baselineStart, end: now, options: .strictStartDate)
        let baselineQuery = HKSampleQuery(sampleType: type, predicate: baselinePredicate, limit: 800, sortDescriptors: nil) { [weak self] _, samples, _ in
            guard let self else { return }
            let values = (samples as? [HKQuantitySample])?.map { $0.quantity.doubleValue(for: unit) } ?? []
            let baseline = Self.calculateBaseline(values: values)
            DispatchQueue.main.async {
                self.storeBaseline(baseline, for: signal)
                self.updateCards()
            }
        }
        healthStore.execute(baselineQuery)
    }

    func fetchMotionFidgeting() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let startDate = now.addingTimeInterval(-15 * 60)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, stats, _ in
            guard let self else { return }
            let steps = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            let perMinute = steps / 15.0
            let fidgetPercent = min(100, max(0, perMinute * 5)) // heuristic mapping to % scale
            DispatchQueue.main.async {
                self.motionValue = fidgetPercent
                self.updateCards()
                self.updateRestState(steps: steps)
            }
        }
        healthStore.execute(query)
    }

    func fetchSkinTemperature() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else { return }
        let unit = HKUnit.degreeCelsius()
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: now.addingTimeInterval(-6 * 3600), end: now, options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 100, sortDescriptors: [sort]) { [weak self] _, samples, _ in
            guard let self else { return }
            let temps = (samples as? [HKQuantitySample])?.map { $0.quantity.doubleValue(for: unit) } ?? []
            DispatchQueue.main.async {
                self.skinTempValues = temps
                self.updateCards()
            }
        }
        healthStore.execute(query)
    }

    func fetchRestState() {
        guard let type = HKObjectType.workoutType() as HKSampleType? else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-30 * 60), end: Date(), options: .strictStartDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1, sortDescriptors: [sort]) { [weak self] _, samples, _ in
            guard let self else { return }
            let workout = samples?.first as? HKWorkout
            DispatchQueue.main.async {
                if let workout, workout.endDate > Date().addingTimeInterval(-10 * 60) {
                    self.stateTitle = "Active"
                    self.stateDetail = "Sensors active • Reducing APS weight"
                } else {
                    self.stateTitle = "At Rest"
                    self.stateDetail = "Sensors active • Good signal quality"
                }
            }
        }
        healthStore.execute(query)
    }
}

// MARK: - Baseline + Cards
private extension PhysioLiveViewModel {
    static func calculateBaseline(values: [Double]) -> PhysioBaseline? {
        guard !values.isEmpty else { return nil }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + pow($1 - mean, 2) } / Double(values.count)
        let sd = sqrt(variance)
        return PhysioBaseline(mean: mean, sd: max(0.1, sd))
    }

    func storeBaseline(_ baseline: PhysioBaseline?, for signal: Signal) {
        baselines[signal] = baseline
        calibrationProgress = baselines.values.compactMap { $0 }.count >= 3 ? 1.0 : 0.5
        calibrationText = calibrationProgress >= 1 ? "Complete" : "Calibrating"
    }

    func updateCards() {
        var newCards: [MetricCard] = []
        let latestHR = series[.hr]?.last?.value
        let latestHRV = series[.hrv]?.last?.value
        let latestRR = series[.rr]?.last?.value
        let latestEDA = series[.eda]?.last?.value

        if let hr = latestHR {
            let card = buildCard(signal: .hr, title: "Heart Rate", value: hr, unit: "BPM", icon: "heart.fill", color: .red)
            newCards.append(card)
        }
        if let hrv = latestHRV {
            let card = buildCard(signal: .hrv, title: "Heart Rate Variability", value: hrv, unit: "ms", icon: "waveform.path.ecg", color: .green)
            newCards.append(card)
        }
        if let rr = latestRR {
            let card = buildCard(signal: .rr, title: "Respiratory Rate", value: rr, unit: "br/min", icon: "lungs.fill", color: .blue)
            newCards.append(card)
        }
        if let eda = latestEDA {
            let card = buildCard(signal: .eda, title: "Electrodermal Activity", value: eda, unit: "peaks/min", icon: "bolt.fill", color: .orange)
            newCards.append(card)
        }
        if let temp = skinTempValues.first {
            let baseline = Self.calculateBaseline(values: skinTempValues)
            let card = buildCard(signal: nil, title: "Skin Temperature", value: temp, unit: "°C", icon: "thermometer", color: .purple, baselineOverride: baseline)
            newCards.append(card)
        }
        if let motionValue {
            let baseline = PhysioBaseline(mean: 0, sd: 10)
            let card = buildCard(signal: nil, title: "Motion / Fidgeting", value: motionValue, unit: "%", icon: "move.3d", color: .teal, baselineOverride: baseline)
            newCards.append(card)
        }
        DispatchQueue.main.async {
            self.cards = newCards
        }
    }

    func buildCard(signal: Signal?, title: String, value: Double, unit: String, icon: String, color: Color, baselineOverride: PhysioBaseline? = nil) -> MetricCard {
        let baseline = baselineOverride ?? (signal.flatMap { baselines[$0] } ?? PhysioBaseline(mean: value, sd: 1))
        let z = baseline.sd > 0 ? (value - baseline.mean) / baseline.sd : 0
        let status: MetricCard.Status
        if z > 1.2 {
            status = .elevated
        } else if z < -1.2 {
            status = .low
        } else {
            status = .normal
        }

        let trend: MetricCard.Trend
        if let series = signal.flatMap({ self.series[$0] }), series.count > 2 {
            let first = series.first?.value ?? value
            let last = series.last?.value ?? value
            if last > first + 1 {
                trend = .up
            } else if last < first - 1 {
                trend = .down
            } else {
                trend = .stable
            }
        } else {
            trend = .stable
        }

        let valueText: String
        if unit == "%" {
            valueText = String(format: "%.0f %%", value)
        } else if unit == "ms" {
            valueText = String(format: "%.0f", value)
        } else {
            valueText = String(format: "%.1f", value)
        }

        return MetricCard(
            signal: signal,
            title: title,
            valueText: valueText,
            unit: unit,
            icon: icon,
            color: color,
            baselineMean: String(format: "%.1f", baseline.mean),
            baselineSD: String(format: "%.1f", baseline.sd),
            status: status,
            trend: trend,
            numericValue: value
        )
    }
}

// MARK: - Helpers
private extension PhysioLiveViewModel {
    func quantityType(for signal: Signal) -> HKQuantityType? {
        switch signal {
        case .hr:
            return HKQuantityType.quantityType(forIdentifier: .heartRate)
        case .hrv:
            return HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .rr:
            if #available(iOS 17.0, *) {
                return HKQuantityType.quantityType(forIdentifier: .respiratoryRate)
            } else {
                return HKQuantityType.quantityType(forIdentifier: .respiratoryRate)
            }
        case .eda:
            if #available(iOS 17.0, *) {
                return HKQuantityType.quantityType(forIdentifier: .electrodermalActivity)
            } else {
                return nil
            }
        }
    }

    func updateRestState(steps: Double) {
        if steps < 40 {
            stateTitle = "At Rest"
            stateDetail = "Sensors active • Good signal quality"
            signalQuality = .good
        } else {
            stateTitle = "Active"
            stateDetail = "Movement detected • Lower physiology weight"
            signalQuality = .ok
        }
    }
}

// MARK: - Number formatting
private extension PhysioLiveViewModel {
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    var formatter: NumberFormatter { Self.numberFormatter }
}
