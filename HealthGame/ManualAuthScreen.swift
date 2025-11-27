import SwiftUI
import Supabase

struct ManualAuthScreen: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignup = false
    @State private var message: String?
    @State private var isLoading = false

    var onAuthSuccess: (Session) -> Void

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(16)
                        .background(Color.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    Text("Anxiety Calculator")
                        .font(.largeTitle).bold()
                    Text(isSignup ? "Create your account" : "Sign in to continue")
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                authButton
                toggleModeButton
                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .padding()
        }
    }

    private var authButton: some View {
        Button {
            Task { await handleAuth() }
        } label: {
            HStack {
                if isLoading { ProgressView() }
                Text(isSignup ? "Sign Up" : "Sign In")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primaryGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 6)
        }
        .disabled(isLoading)
    }

    private var toggleModeButton: some View {
        Button(isSignup ? "Already have an account? Sign In" : "New here? Create an account") {
            isSignup.toggle()
            message = nil
        }
        .font(.caption)
        .foregroundColor(.blue)
    }

    private func handleAuth() async {
        guard !email.isEmpty, !password.isEmpty else {
            message = "Please enter email and password."
            return
        }
        isLoading = true
        do {
            let session = try await SupabaseAuthService.shared.authenticate(email: email, password: password, signup: isSignup)
            onAuthSuccess(session)
        } catch {
            message = error.localizedDescription
        }
        isLoading = false
    }
}
