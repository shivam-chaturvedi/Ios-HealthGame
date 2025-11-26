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

        // Heart
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,

        // Body
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,

        // Sleep
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,

        // Workouts
        HKObjectType.workoutType(),

        // VO2 Max
        HKObjectType.quantityType(forIdentifier: .vo2Max)!
    ]
}
