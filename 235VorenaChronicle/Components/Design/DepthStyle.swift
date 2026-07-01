import SwiftUI

enum DepthLevel {
    case flat
    case raised
    case floating
    case hero

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 6
        case .floating: return 10
        case .hero: return 14
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .raised: return 3
        case .floating: return 5
        case .hero: return 8
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .raised: return 0.28
        case .floating: return 0.34
        case .hero: return 0.42
        }
    }
}

enum DepthStyle {
    static let cardGradient = LinearGradient(
        colors: [Color("AppSurface"), Color("AppSurface").opacity(0.88)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardStroke = LinearGradient(
        colors: [
            Color("AppPrimary").opacity(0.38),
            Color("AppAccent").opacity(0.18),
            Color("AppTextSecondary").opacity(0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [Color("AppPrimary"), Color("AppAccent")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentButtonGradient = LinearGradient(
        colors: [Color("AppAccent"), Color("AppPrimary").opacity(0.85)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let innerHighlight = LinearGradient(
        colors: [Color("AppTextPrimary").opacity(0.1), Color.clear],
        startPoint: .top,
        endPoint: .center
    )

    static let tileGradient = LinearGradient(
        colors: [Color("AppBackground").opacity(0.7), Color("AppBackground").opacity(0.45)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct DepthCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var level: DepthLevel
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DepthStyle.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DepthStyle.cardStroke, lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DepthStyle.innerHighlight)
                    .frame(height: cornerRadius * 1.6)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .compositingGroup()
            .shadow(
                color: Color("AppBackground").opacity(level.shadowOpacity),
                radius: level.shadowRadius,
                y: level.shadowY
            )
    }
}

struct DepthSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat
    var level: DepthLevel

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DepthStyle.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DepthStyle.cardStroke, lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DepthStyle.innerHighlight)
                    .frame(height: cornerRadius * 1.4)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .compositingGroup()
            .shadow(
                color: Color("AppBackground").opacity(level.shadowOpacity),
                radius: level.shadowRadius,
                y: level.shadowY
            )
    }
}

struct DepthButtonModifier: ViewModifier {
    var cornerRadius: CGFloat
    var gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(gradient)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DepthStyle.innerHighlight)
                    .frame(height: cornerRadius * 1.2)
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .compositingGroup()
            .shadow(color: Color("AppPrimary").opacity(0.35), radius: 8, y: 4)
    }
}

extension View {
    func depthCard(cornerRadius: CGFloat = 18, level: DepthLevel = .raised, padding: CGFloat = 16) -> some View {
        modifier(DepthCardModifier(cornerRadius: cornerRadius, level: level, padding: padding))
    }

    func depthSurface(cornerRadius: CGFloat = 18, level: DepthLevel = .raised) -> some View {
        modifier(DepthSurfaceModifier(cornerRadius: cornerRadius, level: level))
    }

    func depthButton(cornerRadius: CGFloat = 14, gradient: LinearGradient = DepthStyle.buttonGradient) -> some View {
        modifier(DepthButtonModifier(cornerRadius: cornerRadius, gradient: gradient))
    }
}
