import SwiftUI
import Supabase

struct ContentView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("auth_access_token") private var accessToken: String?
    @AppStorage("auth_refresh_token") private var refreshToken: String?
    @StateObject private var vm = AnxietyCalculatorViewModel()
    @State private var isRestoringSession = true
    @State private var attemptedRestore = false

    var body: some View {
        Group {
            if isRestoringSession {
                ZStack {
                    AppBackground()
                    ProgressView("Loading session...")
                        .padding()
                }
            } else if accessToken == nil || refreshToken == nil {
                ManualAuthScreen { session in
                    accessToken = session.accessToken
                    refreshToken = session.refreshToken
                }
            } else if onboardingComplete {
                MainAppView()
                    .environmentObject(vm)
            } else {
                OnboardingFlow(completed: $onboardingComplete)
                    .environmentObject(vm)
            }
        }
        .task {
            await restoreSessionIfNeeded()
        }
    }

    private func restoreSessionIfNeeded() async {
        guard !attemptedRestore else { return }
        attemptedRestore = true
        guard let accessToken, let refreshToken else {
            isRestoringSession = false
            return
        }
        do {
            let session = try await SupabaseAuthService.shared.restoreSession(accessToken: accessToken, refreshToken: refreshToken)
            self.accessToken = session.accessToken
            self.refreshToken = session.refreshToken
        } catch {
            self.accessToken = nil
            self.refreshToken = nil
        }
        isRestoringSession = false
    }
}

#Preview {
    ContentView()
        .environmentObject(AnxietyCalculatorViewModel())
}
