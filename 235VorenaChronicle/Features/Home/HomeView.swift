import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStorage
    @Environment(\.selectedAppTab) private var selectedTab
    @State private var showNewStory = false

    private var recentSlides: [StorySlide] {
        store.slides.sorted { $0.date > $1.date }.prefix(8).map { $0 }
    }

    private var digest: WeeklyDigestData {
        AnalyticsService.weeklyDigest(
            slides: store.slides,
            themes: store.themes,
            totalExports: store.totalExports
        )
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        heroBanner
                        statsGrid
                        quickActions
                        recentMomentsSection
                        activeStoriesSection
                        weekWidget
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .sheet(isPresented: $showNewStory) {
                HomeNewStorySheet()
            }
        }
    }

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHeroBanner")
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.1), Color("AppBackground").opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("AppAccent").opacity(0.2))
                    .clipShape(Capsule())

                Text("Your Visual Stories")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))

                Text(Date.now.formatted(date: .complete, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(18)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(DepthStyle.cardStroke, lineWidth: 1)
        )
        .compositingGroup()
        .shadow(color: Color("AppPrimary").opacity(DepthLevel.hero.shadowOpacity), radius: DepthLevel.hero.shadowRadius, y: DepthLevel.hero.shadowY)
    }

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Overview", subtitle: "Your collection at a glance", icon: "square.grid.2x2")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HomeStatWidget(
                    title: "Stories",
                    value: "\(store.themes.count)",
                    icon: "books.vertical.fill",
                    trend: store.themes.isEmpty ? nil : "Active"
                )
                HomeStatWidget(
                    title: "Slides",
                    value: "\(store.slides.count)",
                    icon: "photo.fill",
                    accent: Color("AppAccent")
                )
                HomeStatWidget(
                    title: "Day Streak",
                    value: "\(store.streakDays)",
                    icon: "flame.fill",
                    trend: store.streakDays >= 3 ? "🔥" : nil
                )
                HomeStatWidget(
                    title: "Exports",
                    value: "\(store.totalExports)",
                    icon: "square.and.arrow.up.fill",
                    accent: Color("AppAccent")
                )
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions", icon: "bolt.fill")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    HomeQuickActionWidget(title: "New Story", icon: "plus.circle.fill") {
                        FeedbackManager.buttonTap()
                        showNewStory = true
                    }
                    HomeQuickActionWidget(title: "All Stories", icon: "photo.stack.fill") {
                        switchTab(to: .stories)
                    }
                    HomeQuickActionWidget(title: "Insights", icon: "chart.bar.fill") {
                        switchTab(to: .insights)
                    }
                    HomeQuickActionWidget(title: "Design Card", icon: "rectangle.portrait.on.rectangle.portrait.angled") {
                        switchTab(to: .cards)
                    }
                    HomeQuickActionWidget(title: "Achievements", icon: "star.fill") {
                        switchTab(to: .insights)
                    }
                }
            }
        }
    }

    private var recentMomentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Recent Moments",
                subtitle: recentSlides.isEmpty ? "Add photos to your stories" : "Latest slides across all stories",
                icon: "camera.fill"
            )

            if recentSlides.isEmpty {
                HStack(spacing: 16) {
                    Image("HomeWidgetEmpty")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("No moments yet")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Create a story and add your first photo slide.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Button {
                            FeedbackManager.buttonTap()
                            showNewStory = true
                        } label: {
                            Text("Get Started")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .depthButton(cornerRadius: 20, gradient: DepthStyle.buttonGradient)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    Spacer()
                }
                .depthCard(cornerRadius: 18, level: .raised, padding: 14)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentSlides) { slide in
                            NavigationLink {
                                if let theme = store.themes.first(where: { $0.id == slide.themeID }) {
                                    StoryDetailView(theme: theme)
                                }
                            } label: {
                                HomeMomentWidget(
                                    slide: slide,
                                    theme: store.themes.first { $0.id == slide.themeID }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var activeStoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeaderView(title: "Your Stories", icon: "books.vertical.fill")
                Spacer()
                Button("See All") {
                    switchTab(to: .stories)
                }
                .font(.caption.bold())
                .foregroundStyle(Color("AppPrimary"))
            }

            if store.themes.isEmpty {
                EmptyStateView(
                    icon: "photo.stack",
                    title: "No stories yet",
                    message: "Start building your first visual story.",
                    buttonTitle: "Create Story",
                    action: { showNewStory = true }
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(store.themes.prefix(4)) { theme in
                        NavigationLink {
                            StoryDetailView(theme: theme)
                        } label: {
                            HomeStoryWidget(
                                theme: theme,
                                slides: store.orderedSlides(for: theme)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var weekWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Weekly Snapshot", icon: "calendar")

            NavigationLink {
                WeeklyDigestView()
            } label: {
                HomeWeekWidget(digest: digest, topMood: digest.topMood)
            }
            .buttonStyle(.plain)
        }
    }

    private func switchTab(to tab: AppTab) {
        FeedbackManager.buttonTap()
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedTab?.wrappedValue = tab
        }
    }
}

private struct HomeNewStorySheet: View {
    @EnvironmentObject private var store: AppStorage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ThemeCuratorViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("HomeHeroBanner")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "New Story", icon: "plus.circle.fill")
                            TextField("Story title", text: $viewModel.title)
                                .padding(12)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .depthSurface(cornerRadius: 10, level: .flat)
                            EmojiPickerView(selectedEmoji: $viewModel.emoji)
                        }
                    }

                    PrimaryButton(title: "Create Story", icon: "checkmark") {
                        if viewModel.save(store: store) {
                            dismiss()
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle("New Story")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .onAppear {
                viewModel.title = ""
                viewModel.emoji = "🎨"
                viewModel.description = ""
                viewModel.reflectionPrompt = Theme.defaultReflectionPrompt
                viewModel.titleError = ""
            }
        }
    }
}
