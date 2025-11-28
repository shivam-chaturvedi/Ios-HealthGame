import SwiftUI
import Combine
import Supabase

struct ContentView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("auth_access_token") private var accessToken: String?
    @AppStorage("auth_refresh_token") private var refreshToken: String?
    @AppStorage("last_cloud_sync_iso") private var lastCloudSyncISO: String?
    @StateObject private var vm = AnxietyCalculatorViewModel()
    @State private var isRestoringSession = true
    @State private var attemptedRestore = false
    @Environment(\.scenePhase) private var scenePhase
    private let liveTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

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
                    Task { await vm.refreshUserContext() }
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
        .onReceive(liveTimer) { _ in
            vm.simulateLiveTick()
            Task { await autoSyncIfNeeded() }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                vm.simulateLiveTick()
                Task { await vm.refreshUserContext() }
                Task { await autoSyncIfNeeded() }
            }
        }
        .onChange(of: vm.lastCloudSync) { date in
            if let date {
                let formatter = ISO8601DateFormatter()
                lastCloudSyncISO = formatter.string(from: date)
            }
        }
        .preferredColorScheme(.light)
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
            await vm.refreshUserContext()
        } catch {
            self.accessToken = nil
            self.refreshToken = nil
        }
        isRestoringSession = false
    }

    private func autoSyncIfNeeded() async {
        guard vm.userId != nil else { return }
        let formatter = ISO8601DateFormatter()
        let last = lastCloudSyncISO.flatMap { formatter.date(from: $0) } ?? vm.lastCloudSync
        let now = Date()
        if let last, now.timeIntervalSince(last) < 5 * 3600 {
            return
        }
        await vm.syncWithCloud()
    }
}

#Preview {
    ContentView()
        .environmentObject(AnxietyCalculatorViewModel())
}
