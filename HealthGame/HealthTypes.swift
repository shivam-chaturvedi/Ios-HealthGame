import HealthKit

struct HealthTypes {

    static let allTypes: Set<HKObjectType> = [

        // Activity
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
        HKObjectType.categoryType(forIdentifier: .mindfulSession)!, // self-care sessions
        HKObjectType.quantityType(forIdentifier: .dietaryWater)!,   // hydration
        HKObjectType.quantityType(forIdentifier: .dietaryCaffeine)!, // stimulants

        // Heart
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,

        // Respiratory & EDA
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,

        // Body
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
        HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)!,

        // Sleep
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.categoryType(forIdentifier: .menstrualFlow)!, // cycle tracking

        // Workouts
        HKObjectType.workoutType(),

        // VO2 Max
        HKObjectType.quantityType(forIdentifier: .vo2Max)!
    ]

    // Optional types gated by OS availability
    static var optionalTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = []
        if #available(iOS 17.0, *) {
            if let eda = HKObjectType.quantityType(forIdentifier: .electrodermalActivity) {
                types.insert(eda)
            }
        }
        return types
    }
}
