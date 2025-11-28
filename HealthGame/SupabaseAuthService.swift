import Foundation
import Supabase

enum SupabaseAuthError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let text): return text
        }
    }
}

final class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    private init() {}

    private let client = SupabaseManager.shared.client

    func authenticate(email: String, password: String, signup: Bool) async throws -> Session {
        if signup, let session = try await signUp(email: email, password: password) {
            return session
        }
        
        return try await signIn(email: email, password: password)
    }

    func restoreSession(accessToken: String, refreshToken: String) async throws -> Session {
        do {
            return try await client.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
        } catch {
            throw mapError(error)
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            // Don't block UI on sign-out failures; session tokens will be cleared locally.
        }
    }

    func currentUser() async throws -> User {
        do {
            return try await client.auth.user()
        } catch {
            throw mapError(error)
        }
    }

    private func signUp(email: String, password: String) async throws -> Session? {
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            return response.session
        } catch {
            throw mapError(error)
        }
    }

    private func signIn(email: String, password: String) async throws -> Session {
        do {
            return try await client.auth.signIn(email: email, password: password)
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> SupabaseAuthError {
        if let authError = error as? AuthError {
            return .message(authError.localizedDescription)
        }
        return .message(error.localizedDescription)
    }
}
