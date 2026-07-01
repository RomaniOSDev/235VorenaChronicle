import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        settingsList

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    FeedbackManager.buttonTap()
                }
                Button("Reset", role: .destructive) {
                    FeedbackManager.buttonTap()
                    store.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your stories, slides, photos, exports and progress. This action cannot be undone.")
            }
        }
    }

    private var statsCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                SectionHeaderView(title: "Statistics", subtitle: "Your activity summary", icon: "chart.line.uptrend.xyaxis")
                HStack(spacing: 10) {
                    MetricTileView(value: "\(store.slides.count)", label: "Slides", icon: "photo.fill")
                    MetricTileView(value: "\(store.totalExports)", label: "Exports", icon: "square.and.arrow.up")
                    MetricTileView(value: "\(store.streakDays)", label: "Streak", icon: "flame.fill")
                }
            }
        }
    }

    private var settingsList: some View {
        GlassCard(padding: 0) {
            VStack(spacing: 0) {
                Button {
                    FeedbackManager.buttonTap()
                    rateApp()
                } label: {
                    SettingsRowCell(title: "Rate Us", icon: "star.fill")
                }
                .buttonStyle(.plain)

                divider

                Button {
                    FeedbackManager.buttonTap()
                    openLink(.privacyPolicy)
                } label: {
                    SettingsRowCell(title: "Privacy Policy", icon: "hand.raised.fill")
                }
                .buttonStyle(.plain)

                divider

                Button {
                    FeedbackManager.buttonTap()
                    openLink(.termsOfUse)
                } label: {
                    SettingsRowCell(title: "Terms of Use", icon: "doc.text.fill")
                }
                .buttonStyle(.plain)

                divider

                Button {
                    FeedbackManager.buttonTap()
                    showResetAlert = true
                } label: {
                    SettingsRowCell(title: "Reset All Data", icon: "trash.fill", isDestructive: true, showChevron: false)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("AppTextSecondary").opacity(0.15))
            .frame(height: 1)
            .padding(.leading, 66)
    }

    private func openLink(_ link: AppLink) {
        if let url = URL(string: link.rawValue) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
