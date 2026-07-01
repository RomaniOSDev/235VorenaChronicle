import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 18
    var padding: CGFloat = 16
    var level: DepthLevel = .raised
    private let content: Content

    init(cornerRadius: CGFloat = 18, padding: CGFloat = 16, level: DepthLevel = .raised, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.level = level
        self.content = content()
    }

    var body: some View {
        content
            .depthCard(cornerRadius: cornerRadius, level: level, padding: padding)
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var icon: String?

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(width: 34, height: 34)
                    .background(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.22), Color("AppBackground").opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Color("AppPrimary").opacity(0.25), lineWidth: 0.5)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }

            Spacer()
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String?
    var isEnabled: Bool = true
    var style: ButtonStyleKind = .primary
    let action: () -> Void

    enum ButtonStyleKind {
        case primary, accent, destructive
    }

    var body: some View {
        Button {
            FeedbackManager.buttonTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .depthButton(cornerRadius: 14, gradient: buttonGradient)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var buttonGradient: LinearGradient {
        switch style {
        case .primary: return DepthStyle.buttonGradient
        case .accent: return DepthStyle.accentButtonGradient
        case .destructive:
            return LinearGradient(colors: [Color.red.opacity(0.9), Color.red.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct MetricTileView: View {
    let value: String
    let label: String
    var icon: String?
    var accent: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color("AppPrimary"))
            }
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(accent ? Color("AppAccent") : Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(DepthStyle.tileGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color("AppAccent").opacity(0.12), lineWidth: 0.5)
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppPrimary").opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppAccent").opacity(0.4), Color("AppPrimary").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 100, height: 100)
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, icon: "plus", action: action)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 40)
    }
}

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.buttonTap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 58, height: 58)
                .background(Circle().fill(DepthStyle.buttonGradient))
                .overlay(alignment: .top) {
                    Circle()
                        .fill(DepthStyle.innerHighlight)
                        .frame(width: 58, height: 28)
                        .allowsHitTesting(false)
                }
                .clipShape(Circle())
                .compositingGroup()
                .shadow(color: Color("AppPrimary").opacity(0.4), radius: 10, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
