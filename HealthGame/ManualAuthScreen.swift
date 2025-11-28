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
            AppBackground()
            if isLoading {
                blurOverlay
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection
                    formCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            Image("HomeLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 110, height: 110)
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: AppTheme.shadow, radius: 10, x: 0, y: 10)

            Text("Clinical Anxiety Console")
                .font(.title).bold()
            Text("HIPAA-aligned access to clinically validated signals, assessments, and care team handoffs.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
            LazyVGrid(columns: columns, spacing: 10) {
                heroBadge(text: "HIPAA-aligned security", icon: "lock.shield.fill", color: .blue)
                heroBadge(text: "Encrypted PHI storage", icon: "key.fill", color: .purple)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .background(AppTheme.glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(AppTheme.primaryGradient.opacity(0.5), lineWidth: 1.2)
        )
        .shadow(color: AppTheme.shadow, radius: 18, x: 0, y: 14)
    }

    private var formCard: some View {
        GlassCard(padding: 20, cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSignup ? "Create your clinical account" : "Secure sign-in")
                        .font(.title3).bold()
                    Text("Use your work email to keep your PHI in a HIPAA-safe, clinician-ready workspace.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 12) {
                    inputField(icon: "envelope.fill", placeholder: "Work email", text: $email, keyboard: .emailAddress)
                    inputField(icon: "key.fill", placeholder: "Password", text: $password, isSecure: true)
                }

                authButton

                if let message {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                toggleModeButton

                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.fill")
                        .foregroundColor(.blue)
                    Text("Data encrypted in transit & at rest. Reviewed for HIPAA compliance.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }

    private var authButton: some View {
        Button {
            Task { await handleAuth() }
        } label: {
            HStack {
                if isLoading { ProgressView().tint(.white) }
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
        Button {
            isSignup.toggle()
            message = nil
        } label: {
            Text(isSignup ? "Already have an account? Sign In" : "New here? Create an account")
                .font(.footnote.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
                .foregroundColor(.blue)
                .background(Color.blue.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
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

    private func inputField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default, isSecure: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 26)
            if isSecure {
                SecureField(placeholder, text: text)
                    .textContentType(.password)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboard)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 6)
    }

    private func heroBadge(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline.weight(.semibold))
                .frame(width: 32, height: 32)
                .background(color.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(text)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 82)
        .background(color.opacity(0.08))
        .foregroundColor(color)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.35), lineWidth: 0.8)
        )
    }

    private var blurOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
                Text("Signing \(isSignup ? "up" : "in")...")
                    .foregroundColor(.white)
                    .font(.headline)
                Text("Securing your session")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.caption)
            }
            .padding(24)
            .background(Color.black.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
        }
        .transition(.opacity)
    }
}
