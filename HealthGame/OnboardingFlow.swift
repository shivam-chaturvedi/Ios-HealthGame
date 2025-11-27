import SwiftUI

struct OnboardingFlow: View {
    enum Step: Int, CaseIterable {
        case welcome, purpose, calibration, permissions, concern, complete
    }

    @Binding var completed: Bool
    @State private var step: Step = .welcome
    @State private var selectedConcern: String?
    @State private var permissions: [String: Bool] = [
        "HealthKit": false,
        "Motion": false,
        "Notifications": false
    ]

    private var progress: Double {
        Double(step.rawValue + 1) / Double(Step.allCases.count)
    }

    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                if step != .welcome {
                    ProgressView(value: progress)
                        .tint(.blue)
                        .padding(.top, 12)
                        .padding(.horizontal, 20)
                }

                Spacer()
                VStack(spacing: 22) {
                    switch step {
                    case .welcome: welcome
                    case .purpose: purpose
                    case .calibration: calibration
                    case .permissions: permissionStep
                    case .concern: concernStep
                    case .complete: complete
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                Spacer()
            }
        }
    }
}

private extension OnboardingFlow {
    var welcome: some View {
        VStack(spacing: 18) {
            LottiePlaceholder(symbol: "brain.head.profile")
                .frame(width: 110, height: 110)
            Text("Anxiety Calculator")
                .font(.largeTitle).bold()
            Text("Your personal wellness companion for understanding and managing anxiety in real-time.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Get Started") {
                goNext()
            }
            .buttonStyle(GradientButtonStyle())
            .frame(maxWidth: 320)
        }
        .padding(.top, 40)
    }

    var purpose: some View {
        VStack(spacing: 16) {
            Text("How It Works")
                .font(.title2).bold()
            Text("We combine multiple signals to understand your anxiety levels.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            VStack(spacing: 12) {
                InfoRow(icon: "heart.fill", color: .red, title: "Physiological Tracking", subtitle: "Heart rate, HRV, breathing, and more from your wearable")
                InfoRow(icon: "waveform.path.ecg", color: .blue, title: "Lifestyle Factors", subtitle: "Sleep, caffeine, screen time, and daily habits")
                InfoRow(icon: "brain.head.profile", color: .purple, title: "Quick Check-ins", subtitle: "Brief questionnaires to anchor your score")
            }
            Button("Continue") {
                goNext()
            }
            .buttonStyle(GradientButtonStyle())
        }
    }

    var calibration: some View {
        VStack(spacing: 16) {
            LottiePlaceholder(symbol: "sparkles")
                .frame(width: 96, height: 96)
            Text("Calibration Phase")
                .font(.title2).bold()
            Text("For the first 3 days, we'll learn your unique patterns.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    BulletRow(text: "Passively collect baseline data")
                    BulletRow(text: "Identify your rest patterns")
                    BulletRow(text: "Create personalized baselines")
                    BulletRow(text: "No alerts during this period")
                }
            }
            Button("I Understand") {
                goNext()
            }
            .buttonStyle(GradientButtonStyle())
        }
    }

    var permissionStep: some View {
        VStack(spacing: 16) {
            LottiePlaceholder(symbol: "shield.checkered")
                .frame(width: 96, height: 96)
            Text("Permissions")
                .font(.title2).bold()
            Text("We need a few permissions to help you best.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            VStack(spacing: 10) {
                permissionToggle(key: "HealthKit", description: "Access HR, HRV from your watch")
                permissionToggle(key: "Motion", description: "Track steps and activity levels")
                permissionToggle(key: "Notifications", description: "Send timely interventions")
            }
            Button("Continue") {
                goNext()
            }
            .buttonStyle(GradientButtonStyle())
            Button("Skip for now") {
                goNext()
            }
            .foregroundColor(.secondary)
            .padding(.top, -4)
        }
    }

    func permissionToggle(key: String, description: String) -> some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(key).font(.headline)
                    Text(description).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    permissions[key]?.toggle()
                } label: {
                    Image(systemName: permissions[key] == true ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(permissions[key] == true ? .green : .secondary)
                }
            }
        }
    }

    var concernStep: some View {
        VStack(spacing: 16) {
            Text("Primary Concern").font(.title2).bold()
            Text("What brings you here today?")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            VStack(spacing: 10) {
                concernRow(key: "anxiety", title: "General Anxiety", subtitle: "Persistent worry and nervousness")
                concernRow(key: "stress", title: "Stress", subtitle: "Overwhelm from work or life demands")
                concernRow(key: "panic", title: "Panic", subtitle: "Sudden episodes of intense fear")
            }
            Button("Continue") {
                goNext()
            }
            .buttonStyle(GradientButtonStyle(disabled: selectedConcern == nil))
            .disabled(selectedConcern == nil)
        }
    }

    func concernRow(key: String, title: String, subtitle: String) -> some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    selectedConcern = key
                } label: {
                    Image(systemName: selectedConcern == key ? "largecircle.fill.circle" : "circle")
                        .font(.title3)
                        .foregroundColor(selectedConcern == key ? .blue : .secondary)
                }
            }
        }
    }

    var complete: some View {
        VStack(spacing: 18) {
            LottiePlaceholder(symbol: "checkmark.circle.fill", color: Color(red: 0.10, green: 0.73, blue: 0.54))
                .frame(width: 100, height: 100)
            Text("You're All Set!")
                .font(.title2).bold()
            Text("Your 3-day calibration starts now. We'll notify you when your personalized baselines are ready.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Button("Start Tracking") {
                completed = true
            }
            .buttonStyle(GradientButtonStyle())
            .frame(maxWidth: 320)
        }
    }

    func goNext() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        step = next
    }
}

private struct BulletRow: View {
    var text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .foregroundColor(.blue)
                .font(.subheadline)
            Text(text).font(.subheadline)
        }
    }
}

private struct InfoRow: View {
    var icon: String
    var color: Color
    var title: String
    var subtitle: String

    var body: some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
}

private struct LottiePlaceholder: View {
    var symbol: String
    var color: Color = .blue
    @State private var animate = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.primaryGradient.opacity(0.2))
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.primaryGradient, lineWidth: 1.2)
            Image(systemName: symbol)
                .font(.largeTitle)
                .foregroundColor(color)
                .scaleEffect(animate ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 1).repeatForever(), value: animate)
        }
        .onAppear { animate = true }
    }
}

#Preview {
    OnboardingFlow(completed: .constant(false))
}
