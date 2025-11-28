import Foundation
import Supabase

struct RemotePhysioState: Codable {
    var userId: UUID
    var hr: Double
    var hrv: Double
    var rr: Double
    var eda: Double
    var temp: Double
    var motionScore: Double
    var isExercising: Bool
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case hr, hrv, rr, eda, temp
        case motionScore = "motion_score"
        case isExercising = "is_exercising"
        case updatedAt = "updated_at"
    }
}

struct RemoteLifestyleState: Codable {
    var userId: UUID
    var sleepStart: Date
    var wakeTime: Date
    var sleepDebtHours: Double
    var caffeineMgAfter2pm: Double
    var nicotine: Bool
    var alcoholUnitsAfter8pm: Int
    var activityMinutes: Double
    var vigorousMinutes: Double
    var workloadHours: Double
    var isExamDay: Bool
    var selfCareMinutes: Double
    var hasCycleData: Bool
    var cyclePhase: String
    var post11pmScreenMinutes: Double
    var daytimeScreenHours: Double
    var skippedMeals: Int
    var sugaryItems: Int
    var waterGlasses: Int
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case sleepStart = "sleep_start"
        case wakeTime = "wake_time"
        case sleepDebtHours = "sleep_debt_hours"
        case caffeineMgAfter2pm = "caffeine_mg_after_2pm"
        case nicotine
        case alcoholUnitsAfter8pm = "alcohol_units_after_8pm"
        case activityMinutes = "activity_minutes"
        case vigorousMinutes = "vigorous_minutes"
        case workloadHours = "workload_hours"
        case isExamDay = "is_exam_day"
        case selfCareMinutes = "self_care_minutes"
        case hasCycleData = "has_cycle_data"
        case cyclePhase = "cycle_phase"
        case post11pmScreenMinutes = "post_11pm_screen_minutes"
        case daytimeScreenHours = "daytime_screen_hours"
        case skippedMeals = "skipped_meals"
        case sugaryItems = "sugary_items"
        case waterGlasses = "water_glasses"
        case updatedAt = "updated_at"
    }
}

final class SupabaseSyncService {
    static let shared = SupabaseSyncService()
    private init() {}

    private let client = SupabaseManager.shared.client

    func upsertPhysio(userId: UUID, physio: PhysioData) async {
        let payload = RemotePhysioState(
            userId: userId,
            hr: physio.hr,
            hrv: physio.hrv,
            rr: physio.rr,
            eda: physio.edaPeaksPerMin,
            temp: physio.skinTempDelta,
            motionScore: physio.motionScore,
            isExercising: physio.isExercising,
            updatedAt: Date()
        )
        do {
            _ = try await client.database
                .from("physio_state")
                .upsert(payload, onConflict: "user_id")
                .execute()
        } catch {
            print("Supabase upsertPhysio failed: \(error)")
        }
    }

    func upsertLifestyle(userId: UUID, lifestyle: LifestyleData) async {
        let payload = RemoteLifestyleState(
            userId: userId,
            sleepStart: lifestyle.sleepStart,
            wakeTime: lifestyle.wakeTime,
            sleepDebtHours: lifestyle.sleepDebtHours,
            caffeineMgAfter2pm: lifestyle.caffeineMgAfter2pm,
            nicotine: lifestyle.nicotine,
            alcoholUnitsAfter8pm: lifestyle.alcoholUnitsAfter8pm,
            activityMinutes: lifestyle.activityMinutes,
            vigorousMinutes: lifestyle.vigorousMinutes,
            workloadHours: lifestyle.workloadHours,
            isExamDay: lifestyle.isExamDay,
            selfCareMinutes: lifestyle.selfCareMinutes,
            hasCycleData: lifestyle.hasCycleData,
            cyclePhase: lifestyle.cyclePhase.rawValue,
            post11pmScreenMinutes: lifestyle.post11pmScreenMinutes,
            daytimeScreenHours: lifestyle.daytimeScreenHours,
            skippedMeals: lifestyle.skippedMeals,
            sugaryItems: lifestyle.sugaryItems,
            waterGlasses: lifestyle.waterGlasses,
            updatedAt: Date()
        )
        do {
            _ = try await client.database
                .from("lifestyle_state")
                .upsert(payload, onConflict: "user_id")
                .execute()
        } catch {
            print("Supabase upsertLifestyle failed: \(error)")
        }
    }

    func fetchPhysio(userId: UUID) async -> RemotePhysioState? {
        do {
            let response: PostgrestResponse<RemotePhysioState> = try await client.database
                .from("physio_state")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
            return response.value
        } catch {
            return nil
        }
    }

    func fetchLifestyle(userId: UUID) async -> RemoteLifestyleState? {
        do {
            let response: PostgrestResponse<RemoteLifestyleState> = try await client.database
                .from("lifestyle_state")
                .select()
                .eq("user_id", value: userId.uuidString)
                .single()
                .execute()
            return response.value
        } catch {
            return nil
        }
    }
}
