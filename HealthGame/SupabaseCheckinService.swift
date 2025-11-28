import Foundation
import Supabase

struct RemoteCheckin: Codable, Identifiable {
    var id: UUID?
    var userId: UUID
    var gad2: Int
    var mood: Int
    var gadUpdated: Date
    var moodUpdated: Date
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case gad2 = "gad2"
        case mood = "mood"
        case gadUpdated = "gad_updated"
        case moodUpdated = "mood_updated"
        case createdAt = "created_at"
    }
}

struct RemoteMoment: Codable, Identifiable {
    var id: UUID?
    var userId: UUID
    var note: String
    var intensity: Double
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case note
        case intensity
        case timestamp
    }
}

final class SupabaseCheckinService {
    static let shared = SupabaseCheckinService()
    private init() {}

    private let client = SupabaseManager.shared.client

    func saveCheckin(userId: UUID, data: CheckinData) async {
        let payload = RemoteCheckin(
            id: nil,
            userId: userId,
            gad2: data.gad2Score,
            mood: data.mood,
            gadUpdated: data.gadUpdated,
            moodUpdated: data.moodUpdated,
            createdAt: Date()
        )
        do {
            _ = try await client.database
                .from("checkins")
                .upsert(payload)
                .execute()
        } catch {
            // Avoid blocking UI; log silently
            print("Supabase saveCheckin failed: \(error)")
        }
    }

    func saveMoment(userId: UUID, moment: AnxietyMoment) async {
        let payload = RemoteMoment(
            id: nil,
            userId: userId,
            note: moment.note,
            intensity: moment.intensity,
            timestamp: moment.timestamp
        )
        do {
            _ = try await client.database
                .from("checkin_moments")
                .insert(payload)
                .execute()
        } catch {
            print("Supabase saveMoment failed: \(error)")
        }
    }

    func fetchLatestCheckin(userId: UUID) async -> CheckinData? {
        do {
            let response: PostgrestResponse<[RemoteCheckin]> = try await client.database
                .from("checkins")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
            guard let remote = response.value.first else { return nil }
            return CheckinData(
                gad2Score: remote.gad2,
                gadUpdated: remote.gadUpdated,
                mood: remote.mood,
                moodUpdated: remote.moodUpdated,
                anxietyMoments: []
            )
        } catch {
            print("Supabase fetchLatestCheckin failed: \(error)")
            return nil
        }
    }

    func fetchRecentMoments(userId: UUID, limit: Int = 20) async -> [AnxietyMoment] {
        do {
            let response: PostgrestResponse<[RemoteMoment]> = try await client.database
                .from("checkin_moments")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("timestamp", ascending: false)
                .limit(limit)
                .execute()
            return response.value.map { AnxietyMoment(note: $0.note, timestamp: $0.timestamp, intensity: $0.intensity) }
        } catch {
            print("Supabase fetchRecentMoments failed: \(error)")
            return []
        }
    }
}
