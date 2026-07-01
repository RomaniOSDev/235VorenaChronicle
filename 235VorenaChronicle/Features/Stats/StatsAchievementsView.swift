import SwiftUI

struct StatsAchievementsView: View {
    @EnvironmentObject private var store: AppStorage

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    GlassCard {
                        VStack(spacing: 16) {
                            SectionHeaderView(title: "Your Progress", subtitle: "Keep building your collection", icon: "star.fill")
                            HStack(spacing: 10) {
                                MetricTileView(value: "\(store.slides.count)", label: "Slides", icon: "photo")
                                MetricTileView(value: "\(store.themes.count)", label: "Stories", icon: "books.vertical")
                                MetricTileView(value: "\(store.totalExports)", label: "Exports", icon: "square.and.arrow.up")
                            }
                            HStack(spacing: 10) {
                                MetricTileView(value: "\(store.streakDays)", label: "Streak", icon: "flame.fill")
                                MetricTileView(value: "\(store.totalMinutesUsed)", label: "Minutes", icon: "clock.fill", accent: false)
                                MetricTileView(value: "\(store.totalSessionsCompleted)", label: "Sessions", icon: "bolt.fill", accent: false)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeaderView(
                            title: "Achievements",
                            subtitle: "\(unlockedCount) of \(Achievement.all.count) unlocked",
                            icon: "trophy.fill"
                        )
                        .padding(.horizontal, 4)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Achievement.all) { achievement in
                                AchievementBadgeCell(
                                    achievement: achievement,
                                    isUnlocked: store.isAchievementUnlocked(achievement.id)
                                )
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenStyle()
        .onAppear { store.recordUsageView() }
    }

    private var unlockedCount: Int {
        Achievement.all.filter { store.isAchievementUnlocked($0.id) }.count
    }
}
