import SwiftUI

enum AppTab: Int, CaseIterable {
    case home = 0
    case stories = 1
    case insights = 2
    case cards = 3
    case settings = 4

    var title: String {
        switch self {
        case .home: return "Home"
        case .stories: return "Stories"
        case .insights: return "Insights"
        case .cards: return "Cards"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .stories: return "photo.stack.fill"
        case .insights: return "chart.bar.fill"
        case .cards: return "rectangle.portrait.on.rectangle.portrait.angled"
        case .settings: return "gearshape.fill"
        }
    }
}

enum TabBarMetrics {
    static let barHeight: CGFloat = 72
}

private struct TabBarBottomInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = TabBarMetrics.barHeight
}

extension EnvironmentValues {
    var tabBarBottomInset: CGFloat {
        get { self[TabBarBottomInsetKey.self] }
        set { self[TabBarBottomInsetKey.self] = newValue }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppSurface"), Color("AppSurface").opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(DepthStyle.cardStroke, lineWidth: 1)
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(DepthStyle.innerHighlight)
                .frame(height: 28)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .compositingGroup()
        .shadow(color: Color("AppBackground").opacity(0.45), radius: 12, y: -2)
        .padding(.horizontal, 16)
        .frame(height: TabBarMetrics.barHeight)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            FeedbackManager.buttonTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(DepthStyle.buttonGradient)
                            .frame(width: 40, height: 40)
                            .overlay(alignment: .top) {
                                Circle()
                                    .fill(DepthStyle.innerHighlight)
                                    .frame(width: 40, height: 18)
                                    .allowsHitTesting(false)
                            }
                            .clipShape(Circle())
                            .shadow(color: Color("AppPrimary").opacity(0.35), radius: 4, y: 2)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 18 : 20))
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                }
                Text(tab.title)
                    .font(.caption2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
