import Foundation
import SwiftUI
import HealthKit
import Combine

@MainActor
class HealthDataViewModel: ObservableObject {

    private let healthStore = HKHealthStore()
    private let calendar = Calendar.current

    @Published private(set) var metrics: [HealthMetric] = []
    @Published var authorized = false
    @Published var lastSync: Date?

    init() {
        requestAuthorization()
    }

    func metrics(for category: HealthCategory) -> [HealthMetric] {
        metrics
            .filter { $0.category == category }
            .sorted { $0.title < $1.title }
    }

    func refresh() {
        authorized ? fetchAllData() : requestAuthorization()
    }

    func requestAuthorization() {

        healthStore.requestAuthorization(
            toShare: nil,
            read: HealthTypes.allTypes
        ) { success, _ in

            DispatchQueue.main.async {
                self.authorized = success

                if success {
                    self.fetchAllData()
                }
            }
        }
    }

    // MARK: - Fetch dashboard data
    private func fetchAllData() {
        lastSync = Date()

        // Activity (today totals)
        fetchTodaySum(.stepCount, unit: .count(), title: "Steps", detail: "Today so far", category: .activity, systemImage: "figure.walk", decimals: 0)
        fetchTodaySum(.activeEnergyBurned, unit: .kilocalorie(), title: "Active Energy", detail: "Today so far", category: .activity, systemImage: "flame.fill", decimals: 0, suffix: " kcal")
        fetchTodaySum(.appleExerciseTime, unit: .minute(), title: "Exercise Minutes", detail: "Today so far", category: .activity, systemImage: "figure.strengthtraining.functional", decimals: 0, suffix: " min")
        fetchTodaySum(.flightsClimbed, unit: .count(), title: "Flights Climbed", detail: "Today so far", category: .activity, systemImage: "stairs", decimals: 0)
        fetchTodaySum(.distanceWalkingRunning, unit: .meter(), title: "Walk + Run", detail: "Today so far", category: .activity, systemImage: "figure.run", decimals: 1, suffix: " km") { $0 / 1000 }
        fetchTodaySum(.distanceCycling, unit: .meter(), title: "Cycling Distance", detail: "Today so far", category: .activity, systemImage: "bicycle", decimals: 1, suffix: " km") { $0 / 1000 }

        // Heart
        fetchLatestQuantity(.heartRate, unit: HKUnit(from: "count/min"), title: "Heart Rate", category: .heart, systemImage: "heart.fill", decimals: 0, suffix: " bpm")
        fetchLatestQuantity(.restingHeartRate, unit: HKUnit(from: "count/min"), title: "Resting HR", category: .heart, systemImage: "heart.text.square.fill", decimals: 0, suffix: " bpm")
        fetchLatestQuantity(.walkingHeartRateAverage, unit: HKUnit(from: "count/min"), title: "Walking HR Avg", category: .heart, systemImage: "figure.cooldown", decimals: 0, suffix: " bpm")
        fetchLatestQuantity(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli), title: "HRV", category: .heart, systemImage: "waveform.path.ecg", decimals: 0, suffix: " ms")
        fetchLatestQuantity(.vo2Max, unit: HKUnit(from: "ml/kg*min"), title: "VO₂ Max", category: .heart, systemImage: "lungs.fill", decimals: 1)

        // Body
        fetchLatestQuantity(.bodyMass, unit: .gramUnit(with: .kilo), title: "Weight", category: .body, systemImage: "scalemass", decimals: 1, suffix: " kg")
        fetchLatestQuantity(.height, unit: .meter(), title: "Height", category: .body, systemImage: "ruler", decimals: 2, suffix: " m")
        fetchLatestQuantity(.bodyMassIndex, unit: .count(), title: "BMI", category: .body, systemImage: "person.text.rectangle", decimals: 1)

        // Sleep & Workouts
        fetchSleepData()
        fetchWorkoutData()
    }

    // MARK: - Helpers
    private func fetchTodaySum(_ id: HKQuantityTypeIdentifier,
                               unit: HKUnit,
                               title: String,
                               detail: String,
                               category: HealthCategory,
                               systemImage: String,
                               decimals: Int,
                               suffix: String = "",
                               valueTransform: ((Double) -> Double)? = nil) {

        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return }

        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, stats, _ in
            guard let self else { return }
            guard let quantity = stats?.sumQuantity() else { return }

            var value = quantity.doubleValue(for: unit)
            if let transform = valueTransform {
                value = transform(value)
            }

            let valueString = self.formatValue(value, decimals: decimals, suffix: suffix)

            DispatchQueue.main.async {
                self.updateMetric(
                    id: self.metricId(category: category, title: title),
                    title: title,
                    value: valueString,
                    detail: detail,
                    category: category,
                    systemImage: systemImage
                )
            }
        }

        healthStore.execute(query)
    }

    private func fetchLatestQuantity(_ id: HKQuantityTypeIdentifier,
                                     unit: HKUnit,
                                     title: String,
                                     category: HealthCategory,
                                     systemImage: String,
                                     decimals: Int,
                                     suffix: String = "",
                                     valueTransform: ((Double) -> Double)? = nil) {

        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { [weak self] _, samples, _ in
            guard let self else { return }
            guard let sample = samples?.first as? HKQuantitySample else { return }

            var value = sample.quantity.doubleValue(for: unit)
            if let transform = valueTransform {
                value = transform(value)
            }

            let valueString = self.formatValue(value, decimals: decimals, suffix: suffix)
            let detail = "Last reading: \(self.timeFormatter.string(from: sample.endDate))"

            DispatchQueue.main.async {
                self.updateMetric(
                    id: self.metricId(category: category, title: title),
                    title: title,
                    value: valueString,
                    detail: detail,
                    category: category,
                    systemImage: systemImage
                )
            }
        }

        healthStore.execute(query)
    }

    private func fetchSleepData() {

        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: type,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { [weak self] _, samples, _ in
            guard let self else { return }
            guard let sample = samples?.first as? HKCategorySample else { return }

            let durationHours = sample.endDate.timeIntervalSince(sample.startDate) / 3600
            let value = self.formatValue(durationHours, decimals: 1, suffix: " hrs")
            let detail = "Ended at \(self.timeFormatter.string(from: sample.endDate))"

            DispatchQueue.main.async {
                self.updateMetric(
                    id: self.metricId(category: .sleep, title: "Sleep"),
                    title: "Sleep",
                    value: value,
                    detail: detail,
                    category: .sleep,
                    systemImage: "moon.zzz.fill"
                )
            }
        }

        healthStore.execute(query)
    }

    private func fetchWorkoutData() {

        let workoutType = HKObjectType.workoutType()
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sort]
        ) { [weak self] _, samples, _ in
            guard let self else { return }
            guard let workout = samples?.first as? HKWorkout else { return }

            let minutes = Int(workout.duration / 60)
            let calories = Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
            let distanceMeters = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
            let distanceText = distanceMeters > 0 ? " • \(self.formatValue(distanceMeters / 1000, decimals: 1, suffix: " km"))" : ""
            let value = "\(minutes) min • \(calories) kcal\(distanceText)"
            let detail = "\(workout.workoutActivityType.displayName) • \(self.dateFormatter.string(from: workout.endDate))"

            DispatchQueue.main.async {
                self.updateMetric(
                    id: self.metricId(category: .workouts, title: "Last Workout"),
                    title: "Last Workout",
                    value: value,
                    detail: detail,
                    category: .workouts,
                    systemImage: "bolt.heart.fill"
                )
            }
        }

        healthStore.execute(query)
    }

    private func updateMetric(id: String,
                              title: String,
                              value: String,
                              detail: String,
                              category: HealthCategory,
                              systemImage: String) {

        let metric = HealthMetric(
            id: id,
            title: title,
            value: value,
            detail: detail,
            category: category,
            systemImage: systemImage
        )

        if let index = metrics.firstIndex(where: { $0.id == id }) {
            metrics[index] = metric
        } else {
            metrics.append(metric)
        }
    }

    private func metricId(category: HealthCategory, title: String) -> String {
        "\(category.rawValue)-\(title)"
    }

    private func formatValue(_ value: Double, decimals: Int, suffix: String = "") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals > 0 ? 1 : 0
        let numberString = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(decimals)f", value)
        return numberString + suffix
    }

    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

private extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .traditionalStrengthTraining: return "Strength"
        case .functionalStrengthTraining: return "Functional Strength"
        case .highIntensityIntervalTraining: return "HIIT"
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .yoga: return "Yoga"
        case .swimming: return "Swimming"
        case .hiking: return "Hiking"
        case .mindAndBody: return "Mind & Body"
        case .dance: return "Dance"
        case .pilates: return "Pilates"
        case .rowing: return "Rowing"
        case .stairs: return "Stairs"
        case .stairClimbing: return "Stair Climb"
        case .elliptical: return "Elliptical"
        case .crossTraining: return "Cross Training"
        case .coreTraining: return "Core Training"
        case .martialArts: return "Martial Arts"
        case .boxing: return "Boxing"
        case .jumpRope: return "Jump Rope"
        case .wheelchairWalkPace: return "Wheelchair Walk"
        case .wheelchairRunPace: return "Wheelchair Run"
        case .golf: return "Golf"
        case .tennis: return "Tennis"
        case .basketball: return "Basketball"
        case .soccer: return "Soccer"
        case .americanFootball: return "Football"
        case .australianFootball: return "Australian Football"
        case .lacrosse: return "Lacrosse"
        case .pickleball: return "Pickleball"
        default: return "Workout"
        }
    }
}
