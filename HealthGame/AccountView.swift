import SwiftUI
import Supabase

struct AccountView: View {
    @StateObject private var vm = AccountViewModel()
    @AppStorage("auth_access_token") private var accessToken: String?
    @AppStorage("auth_refresh_token") private var refreshToken: String?
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var showDeleteConfirm = false
    @State private var didLoad = false

    private var profile: Profile? { vm.profile }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        heroCard
                        if let error = vm.error {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        statGrid
                        personalInfo
                        quickSettings
                        actionButtons
                        footer
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 16)
                }
                if vm.savedBanner {
                    toast("Saved changes")
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            if !didLoad {
                didLoad = true
                await vm.load()
            }
        }
        .alert("Delete account?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                Task {
                    await vm.deleteAccount()
                    clearSession()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove your profile data from Supabase.")
        }
    }

    private var heroCard: some View {
        GlassCard {
            SectionHeader(title: "Account", subtitle: "Manage your profile", icon: "person.crop.circle.fill")
            VStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 110, height: 110)
                        .overlay(
                            Text(initials(for: profile?.fullName))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )
                    Image(systemName: "camera.fill")
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.shadow, radius: 6, x: 0, y: 4)
                        .offset(x: 10, y: 8)
                }
                Text(profile?.fullName ?? "Your Name")
                    .font(.title3).bold()
                Text(profile?.email ?? "email@example.com")
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    pill("Premium Member", color: Color.green)
                    if let days = profile?.daysActive {
                        pill("Day \(days)", color: Color.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var statGrid: some View {
        HStack(spacing: 12) {
            statCard(icon: "calendar", title: "Days Active", value: "\(profile?.daysActive ?? 1)")
            statCard(icon: "checkmark.circle.fill", title: "Check-Ins", value: "\(profile?.checkIns ?? 0)")
            statCard(icon: "flame.fill", title: "Streak", value: "\(profile?.streak ?? 0)")
            let improvementValue = Int(profile?.improvement ?? 0)
            statCard(icon: "chart.line.uptrend.xyaxis", title: "Growth", value: "\(improvementValue)%")
        }
    }

    private var personalInfo: some View {
        GlassCard {
            SectionHeader(title: "Personal Information", subtitle: "Keep your details up to date", icon: "person.text.rectangle.fill")
            VStack(spacing: 14) {
                infoField(icon: "person.fill", title: "Full Name", binding: binding(\.fullName), placeholder: "Your name")
                Divider()
                infoField(icon: "envelope.fill", title: "Email Address", binding: binding(\.email), placeholder: "email@example.com", keyboard: .emailAddress)
                Divider()
                infoField(icon: "phone.fill", title: "Phone Number", binding: binding(\.phone), placeholder: "+1 (555) 123-4567", keyboard: .phonePad)
                Divider()
                infoField(icon: "calendar", title: "Date of Birth", binding: binding(\.dateOfBirth), placeholder: "YYYY-MM-DD")
            }
            Button {
                Task { await vm.saveChanges() }
            } label: {
                HStack {
                    if vm.isSaving { ProgressView() }
                    Text(vm.isSaving ? "Saving..." : "Save Changes")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primaryGradient)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 6)
            }
            .disabled(vm.isSaving || profile == nil)
        }
    }

    private var quickSettings: some View {
        GlassCard {
            SectionHeader(title: "Quick Settings", subtitle: "Control alerts and theme", icon: "slider.horizontal.3")
            VStack(spacing: 14) {
                settingRow(icon: "bell.badge.fill", color: .purple, title: "Notifications", subtitle: "Manage alert preferences")
                Divider()
                settingRow(icon: "shield.fill", color: .blue, title: "Privacy", subtitle: "Data and security settings")
                Divider()
                settingRow(icon: "moon.fill", color: .indigo, title: "Appearance", subtitle: "Theme and display")
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await SupabaseAuthService.shared.signOut()
                    clearSession()
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out").fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.12))
                .foregroundColor(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete Account").fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.12))
                .foregroundColor(.red)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var footer: some View {
        GlassCard {
            VStack(spacing: 4) {
                Text("Anxiety Calculator").font(.subheadline).bold()
                Text("Version 1.0.0").font(.caption).foregroundColor(.secondary)
                Text("Made with ❤️ for your wellbeing").font(.caption2).foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func infoField(icon: String, title: String, binding: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .padding(10)
                .background(Color.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.caption).foregroundColor(.secondary)
                TextField(placeholder, text: binding)
                    .keyboardType(keyboard)
            }
            Spacer()
            Image(systemName: "pencil")
                .foregroundColor(.secondary)
        }
    }

    private func settingRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .padding(10)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        GlassCard(padding: 12, cornerRadius: 18) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(value)
                    .font(.headline)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func pill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private func toast(_ text: String) -> some View {
        Text(text)
            .font(.subheadline).bold()
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 4)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { vm.savedBanner = false }
                }
            }
            .padding(.top, 12)
    }

    private func initials(for name: String?) -> String {
        guard let name else { return "AC" }
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.map(String.init).joined().uppercased()
    }

    private func binding(_ keyPath: WritableKeyPath<Profile, String?>) -> Binding<String> {
        Binding<String>(
            get: { profile?[keyPath: keyPath] ?? "" },
            set: { newValue in
                vm.profile?[keyPath: keyPath] = newValue.isEmpty ? nil : newValue
            }
        )
    }

    private func clearSession() {
        accessToken = nil
        refreshToken = nil
        onboardingComplete = false
    }
}
