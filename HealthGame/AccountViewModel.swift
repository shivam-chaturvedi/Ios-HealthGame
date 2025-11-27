import Foundation
import Combine
import Supabase

@MainActor
final class AccountViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var error: String?
    @Published var savedBanner = false

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await SupabaseAuthService.shared.currentUser()
            profile = try await ProfileService.shared.fetchProfile(for: user)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func saveChanges() async {
        guard var profile else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            profile = try await ProfileService.shared.upsert(profile: profile)
            self.profile = profile
            savedBanner = true
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteAccount() async {
        guard let userId = profile?.id else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            try await ProfileService.shared.deleteProfile(userId: userId)
            await SupabaseAuthService.shared.signOut()
            profile = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
