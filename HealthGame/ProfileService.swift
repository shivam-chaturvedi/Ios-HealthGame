import Foundation
import Supabase

struct Profile: Codable, Identifiable, Equatable {
    var id: UUID
    var fullName: String?
    var email: String?
    var phone: String?
    var avatarUrl: String?
    var dateOfBirth: String?
    var membership: String?
    var daysActive: Int?
    var checkIns: Int?
    var streak: Int?
    var improvement: Double?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case phone
        case avatarUrl = "avatar_url"
        case dateOfBirth = "date_of_birth"
        case membership
        case daysActive = "days_active"
        case checkIns = "check_ins"
        case streak
        case improvement
        case updatedAt = "updated_at"
    }

    static func empty(for user: User) -> Profile {
        let fallbackName = user.email ?? "Member"
        let profile = Profile(
            id: user.id,
            fullName: fallbackName,
            email: user.email,
            phone: nil,
            avatarUrl: nil,
            dateOfBirth: nil,
            membership: "Member",
            daysActive: 1,
            checkIns: 0,
            streak: 0,
            improvement: nil,
            updatedAt: nil
        )
        return profile
    }
}

enum ProfileServiceError: LocalizedError {
    case noSession
    case message(String)

    var errorDescription: String? {
        switch self {
        case .noSession: return "You need to sign in first."
        case .message(let text): return text
        }
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private let client = SupabaseManager.shared.client

    func fetchProfile(for user: User) async throws -> Profile {
        do {
            let response: PostgrestResponse<Profile> = try await client.database
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .single()
                .execute()
            return response.value
        } catch {
            // If the profile does not exist yet, return an empty shell we can upsert.
            return Profile.empty(for: user)
        }
    }

    func upsert(profile: Profile) async throws -> Profile {
        do {
            let response: PostgrestResponse<Profile> = try await client.database
                .from("profiles")
                .upsert(profile, onConflict: "id")
                .select()
                .single()
                .execute()
            return response.value
        } catch {
            throw mapError(error)
        }
    }

    func deleteProfile(userId: UUID) async throws {
        do {
            try await client.database
                .from("profiles")
                .delete()
                .eq("id", value: userId.uuidString)
                .execute()
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> ProfileServiceError {
        if let postgrestError = error as? PostgrestError {
            return .message(postgrestError.message)
        }
        return .message(error.localizedDescription)
    }
}
