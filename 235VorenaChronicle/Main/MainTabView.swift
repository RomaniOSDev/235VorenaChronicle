import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppStorage
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .home
    @State private var pendingAchievements: [Achievement] = []
    @State private var showingBanner = false

    var body: some View {
        GeometryReader { proxy in
            let bottomSafeArea = proxy.safeAreaInsets.bottom
            let tabBarInset = TabBarMetrics.barHeight + bottomSafeArea

            ZStack(alignment: .bottom) {
                AppBackgroundView()
                    .ignoresSafeArea()

                tabContent
                    .environment(\.selectedAppTab, $selectedTab)
                    .environment(\.tabBarBottomInset, tabBarInset)
                    .padding(.bottom, tabBarInset)

                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, bottomSafeArea)
            }
        }
        .overlay(alignment: .top) {
            if showingBanner, let achievement = pendingAchievements.first {
                AchievementBannerView(achievement: achievement) {
                    pendingAchievements.removeFirst()
                    if pendingAchievements.isEmpty {
                        showingBanner = false
                    } else {
                        showingBanner = true
                    }
                    store.clearNewlyUnlockedAchievement()
                }
                .padding(.top, 8)
            }
        }
        .onChange(of: store.newlyUnlockedAchievement) { achievement in
            if let achievement {
                pendingAchievements.append(achievement)
                if !showingBanner {
                    showingBanner = true
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.startSessionTimer()
            case .background, .inactive:
                store.stopSessionTimer()
            @unknown default:
                break
            }
        }
        .onAppear {
            store.startSessionTimer()
            store.checkAchievements()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .stories:
            ThemeCuratorView()
        case .insights:
            InsightsHubView()
        case .cards:
            CardDesignerView()
        case .settings:
            SettingsView()
        }
    }
}
