import SwiftUI

struct AppTheme {
    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.08, green: 0.62, blue: 0.94), Color(red: 0.20, green: 0.82, blue: 0.70)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let background = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.97, blue: 1.0),
            Color(red: 0.92, green: 0.96, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassBackground = Color.white.opacity(0.55)
    static let shadow = Color.black.opacity(0.06)
}

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 20
    var content: () -> Content

    init(padding: CGFloat = 16, cornerRadius: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(AppTheme.glassBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
        )
        .shadow(color: AppTheme.shadow, radius: 12, x: 0, y: 8)
    }
}

struct GradientButtonStyle: ButtonStyle {
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.primaryGradient)
            .opacity(disabled ? 0.5 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppTheme.shadow, radius: 10, x: 0, y: 10)
    }
}

struct SectionHeader: View {
    var title: String
    var subtitle: String?
    var icon: String?

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.headline)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
    }
}

struct ConfidenceBadgeView: View {
    var confidence: ConfidenceLevel

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.caption)
            Text(confidence.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(confidenceColor.opacity(0.15))
        .foregroundColor(confidenceColor)
        .clipShape(Capsule())
    }

    private var confidenceColor: Color {
        switch confidence {
        case .high:
            return .green
        case .medium:
            return .orange
        case .low:
            return .red
        }
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 420)
                .blur(radius: 90)
                .offset(x: -120, y: -240)
            Circle()
                .fill(Color.green.opacity(0.08))
                .frame(width: 380)
                .blur(radius: 90)
                .offset(x: 160, y: 200)
        }
    }
}

extension View {
    func pillTag(_ text: String, color: Color = .blue) -> some View {
        overlay(
            HStack {
                Text(text)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.12))
                    .foregroundColor(color)
                    .clipShape(Capsule())
                Spacer()
            }
        )
    }
}
