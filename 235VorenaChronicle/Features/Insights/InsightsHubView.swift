import SwiftUI
import Charts

struct InsightsHubView: View {
    @EnvironmentObject private var store: AppStorage

    private var unlockedCount: Int {
        Achievement.all.filter { store.isAchievementUnlocked($0.id) }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 16) {
                        overviewCard

                        VStack(spacing: 10) {
                            NavigationLink {
                                ThemeAnalyticsView()
                            } label: {
                                InsightMenuCell(
                                    title: "Theme Analytics",
                                    subtitle: "Charts for themes, moods & weekday activity",
                                    icon: "chart.bar.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                CompareThemesView()
                            } label: {
                                InsightMenuCell(
                                    title: "Compare Themes",
                                    subtitle: "Side-by-side gallery comparison",
                                    icon: "square.split.2x1.fill",
                                    badge: store.themes.count >= 2 ? "Ready" : nil
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                SmartGroupingView()
                            } label: {
                                InsightMenuCell(
                                    title: "Smart Grouping",
                                    subtitle: "Auto-grouped by mood & theme",
                                    icon: "square.grid.3x3.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                WeeklyDigestView()
                            } label: {
                                InsightMenuCell(
                                    title: "Weekly Digest",
                                    subtitle: "Your week in media at a glance",
                                    icon: "calendar"
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                StatsAchievementsView()
                            } label: {
                                InsightMenuCell(
                                    title: "Achievements",
                                    subtitle: "Badges and progress milestones",
                                    icon: "star.fill",
                                    badge: "\(unlockedCount)/\(Achievement.all.count)"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
        }
    }

    private var overviewCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                SectionHeaderView(title: "Overview", subtitle: "Your collection at a glance", icon: "sparkles")
                HStack(spacing: 10) {
                    MetricTileView(value: "\(store.themes.count)", label: "Stories", icon: "books.vertical")
                    MetricTileView(value: "\(store.slides.count)", label: "Slides", icon: "photo")
                    MetricTileView(value: "\(store.streakDays)", label: "Streak", icon: "flame.fill")
                }
            }
        }
    }
}

struct ThemeAnalyticsView: View {
    @EnvironmentObject private var store: AppStorage

    private var themeData: [ThemeFrequencyItem] {
        AnalyticsService.themeFrequency(themes: store.themes, slides: store.slides)
    }

    private var moodData: [MoodFrequencyItem] {
        AnalyticsService.topMoodTags(slides: store.slides)
    }

    private var weekdayData: [(String, Int)] {
        let values = AnalyticsService.activityByWeekday(slides: store.slides)
        return zip(AnalyticsService.weekdayLabels, values).map { ($0, $1) }
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 16) {
                    chartCard(title: "Slides per Theme", icon: "books.vertical.fill") {
                        if themeData.isEmpty {
                            emptyChartText
                        } else {
                            Chart(themeData) { item in
                                BarMark(
                                    x: .value("Theme", item.title),
                                    y: .value("Slides", item.slideCount)
                                )
                                .foregroundStyle(Color("AppPrimary"))
                                .cornerRadius(6)
                            }
                            .frame(height: 220)
                        }
                    }

                    chartCard(title: "Top Mood Tags", icon: "face.smiling.fill") {
                        if moodData.isEmpty {
                            emptyChartText
                        } else {
                            Chart(moodData) { item in
                                BarMark(
                                    x: .value("Mood", item.mood.label),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(Color("AppAccent"))
                                .cornerRadius(6)
                            }
                            .frame(height: 220)
                        }
                    }

                    chartCard(title: "Activity by Weekday", icon: "calendar") {
                        if store.slides.isEmpty {
                            emptyChartText
                        } else {
                            Chart(weekdayData, id: \.0) { item in
                                BarMark(
                                    x: .value("Day", item.0),
                                    y: .value("Slides", item.1)
                                )
                                .foregroundStyle(Color("AppAccent"))
                                .cornerRadius(6)
                            }
                            .frame(height: 220)
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Theme Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenStyle()
        .onAppear { store.recordUsageView() }
    }

    private var emptyChartText: some View {
        Text("Add story slides to see analytics")
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity, minHeight: 120)
    }

    private func chartCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(title: title, icon: icon)
                content()
            }
        }
    }
}

struct CompareThemesView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var leftThemeID: UUID?
    @State private var rightThemeID: UUID?

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        themePicker(selection: $leftThemeID, label: "Left", fallback: store.themes.first?.id)
                        themePicker(selection: $rightThemeID, label: "Right", fallback: store.themes.dropFirst().first?.id ?? store.themes.first?.id)
                    }

                    if let left = selectedTheme(leftThemeID), let right = selectedTheme(rightThemeID) {
                        HStack(alignment: .top, spacing: 12) {
                            compareColumn(theme: left, accent: Color("AppPrimary"))
                            compareColumn(theme: right, accent: Color("AppAccent"))
                        }
                    } else {
                        EmptyStateView(
                            icon: "square.split.2x1.fill",
                            title: "Select two stories",
                            message: "Pick two themes to compare their slides side by side."
                        )
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Compare Themes")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenStyle()
        .onAppear {
            store.recordUsageView()
            syncCompareThemeIDs()
        }
        .onChange(of: store.themes) { _ in
            syncCompareThemeIDs()
        }
    }

    private func syncCompareThemeIDs() {
        if leftThemeID == nil || !store.themes.contains(where: { $0.id == leftThemeID }) {
            leftThemeID = store.themes.first?.id
        }
        if rightThemeID == nil || !store.themes.contains(where: { $0.id == rightThemeID }) {
            rightThemeID = store.themes.dropFirst().first?.id ?? store.themes.first?.id
        }
    }

    private func selectedTheme(_ id: UUID?) -> Theme? {
        guard let id else { return nil }
        return store.themes.first { $0.id == id }
    }

    private func themePicker(selection: Binding<UUID?>, label: String, fallback: UUID?) -> some View {
        GlassCard(padding: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                Picker(label, selection: themeSelectionBinding(selection, fallback: fallback)) {
                    ForEach(store.themes) { theme in
                        Text("\(theme.emoji) \(theme.title)").tag(theme.id)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color("AppAccent"))
            }
        }
    }

    private func themeSelectionBinding(_ selection: Binding<UUID?>, fallback: UUID?) -> Binding<UUID> {
        Binding(
            get: {
                if let id = selection.wrappedValue,
                   store.themes.contains(where: { $0.id == id }) {
                    return id
                }
                if let fallback,
                   store.themes.contains(where: { $0.id == fallback }) {
                    return fallback
                }
                return store.themes.first!.id
            },
            set: { selection.wrappedValue = $0 }
        )
    }

    private func compareColumn(theme: Theme, accent: Color) -> some View {
        let slides = store.orderedSlides(for: theme)
        return VStack(spacing: 10) {
            Text(theme.emoji)
                .font(.largeTitle)
            Text(theme.title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text("\(slides.count) slides")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(accent.opacity(0.2))
                .clipShape(Capsule())

            ForEach(slides.prefix(5)) { slide in
                VStack(spacing: 6) {
                    PhotoThumbnailView(slide: slide, size: 90, showBorder: true, cornerRadius: 12)
                    Text(slide.caption)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    MoodChipView(mood: slide.moodTag, compact: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .depthSurface(cornerRadius: 18, level: .raised)
    }
}

struct SmartGroupingView: View {
    @EnvironmentObject private var store: AppStorage

    private var groups: [SmartGroup] {
        AnalyticsService.smartGroups(slides: store.slides, themes: store.themes)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                if groups.isEmpty {
                    EmptyStateView(
                        icon: "square.grid.3x3.fill",
                        title: "No groups yet",
                        message: "Add slides with mood tags to see smart groupings."
                    )
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(groups) { group in
                            GroupCollectionCell(group: group)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Smart Grouping")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenStyle()
        .onAppear { store.recordUsageView() }
    }
}

struct WeeklyDigestView: View {
    @EnvironmentObject private var store: AppStorage

    private var digest: WeeklyDigestData {
        AnalyticsService.weeklyDigest(
            slides: store.slides,
            themes: store.themes,
            totalExports: store.totalExports
        )
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeaderView(title: "Your Week in Media", subtitle: "Last 7 days summary", icon: "calendar")
                            if let mood = digest.topMood {
                                HStack(spacing: 8) {
                                    MoodChipView(mood: mood)
                                    Text("Top mood this week")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }
                    }

                    DigestStatCell(value: "\(digest.slidesAdded)", label: "Slides Added", icon: "photo.stack", trend: "This week")
                    DigestStatCell(value: "\(digest.themesUpdated)", label: "Stories Updated", icon: "books.vertical")
                    DigestStatCell(value: "\(digest.activeDays)", label: "Active Days", icon: "calendar")
                    DigestStatCell(value: "\(digest.exportsCount)", label: "Total Exports", icon: "square.and.arrow.up")
                }
                .padding(16)
            }
        }
        .navigationTitle("Weekly Digest")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenStyle()
        .onAppear { store.recordUsageView() }
    }
}
