import SwiftUI

struct StoryDetailView: View {
    @EnvironmentObject private var store: AppStorage
    @StateObject private var viewModel = StoryDetailViewModel()
    @State private var theme: Theme

    init(theme: Theme) {
        _theme = State(initialValue: theme)
    }

    private var orderedSlides: [StorySlide] {
        guard let current = store.themes.first(where: { $0.id == theme.id }) else {
            return store.orderedSlides(for: theme)
        }
        return store.orderedSlides(for: current)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    quickActions
                    reflectionSection
                    timelineSection
                    exportSection
                }
                .padding(16)
                .padding(.bottom, 32)
            }

            SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showSuccessCheckmark)
        }
        .navigationTitle("Visual Story")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    FeedbackManager.buttonTap()
                    viewModel.startAddingSlide(themeID: theme.id)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    FeedbackManager.buttonTap()
                    viewModel.isEditingOrder.toggle()
                } label: {
                    Label(
                        viewModel.isEditingOrder ? "Done" : "Reorder",
                        systemImage: viewModel.isEditingOrder ? "checkmark" : "arrow.up.arrow.down"
                    )
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppAccent"))
                }
            }
        }
        .sheet(item: $viewModel.editingSlide) { slide in
            SlideEditorView(
                slide: slide,
                isNew: !store.slides.contains(where: { $0.id == slide.id })
            )
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            ShareSheet(items: viewModel.exportItems)
        }
        .onChange(of: store.themes) { themes in
            if let updated = themes.first(where: { $0.id == theme.id }) {
                theme = updated
            }
        }
    }

    private var headerSection: some View {
        GlassCard(level: .floating) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color("AppPrimary").opacity(0.35), Color("AppBackground").opacity(0.6)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 45
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color("AppPrimary").opacity(0.3), lineWidth: 1)
                        )
                    Text(theme.emoji)
                        .font(.system(size: 40))
                }

                Text(theme.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                if !theme.description.isEmpty {
                    Text(theme.description)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                }

                if !orderedSlides.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(orderedSlides.prefix(8)) { slide in
                                PhotoThumbnailView(slide: slide, size: 56, showBorder: true)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            quickActionButton(icon: "photo.badge.plus", title: "Add Slide") {
                viewModel.startAddingSlide(themeID: theme.id)
            }
            quickActionButton(icon: "doc.fill", title: "Export PDF", disabled: orderedSlides.isEmpty) {
                viewModel.exportPDF(theme: theme, slides: orderedSlides, store: store)
            }
        }
    }

    private func quickActionButton(icon: String, title: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.buttonTap()
            action()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .depthSurface(cornerRadius: 14, level: .flat)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(disabled)
        .opacity(disabled ? 0.4 : 1)
    }

    private var reflectionSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeaderView(title: "Reflection", subtitle: "Capture what this story means to you", icon: "text.quote")

                Picker("Prompt", selection: $theme.reflectionPrompt) {
                    ForEach(Theme.reflectionPromptOptions, id: \.self) { prompt in
                        Text(prompt).tag(prompt)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color("AppAccent"))

                Text(theme.reflectionPrompt)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .depthSurface(cornerRadius: 10, level: .flat)

                TextField("Your reflection...", text: $theme.reflectionAnswer, axis: .vertical)
                    .lineLimit(2...5)
                    .padding(12)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .depthSurface(cornerRadius: 10, level: .flat)
                    .onChange(of: theme.reflectionAnswer) { _ in
                        store.updateTheme(theme)
                    }
                    .onChange(of: theme.reflectionPrompt) { _ in
                        FeedbackManager.buttonTap()
                        store.updateTheme(theme)
                    }
            }
        }
    }

    private var timelineSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(
                    title: "Story Timeline",
                    subtitle: "\(orderedSlides.count) slide\(orderedSlides.count == 1 ? "" : "s")",
                    icon: "timeline.selection"
                )

                if orderedSlides.isEmpty {
                    EmptyStateView(
                        icon: "photo.on.rectangle.angled",
                        title: "Empty timeline",
                        message: "Add photos to build your visual story.",
                        buttonTitle: "Add First Slide",
                        action: { viewModel.startAddingSlide(themeID: theme.id) }
                    )
                } else if viewModel.isEditingOrder {
                    List {
                        ForEach(Array(orderedSlides.enumerated()), id: \.element.id) { index, slide in
                            SlideTimelineCell(
                                index: index + 1,
                                slide: slide,
                                isLast: index == orderedSlides.count - 1,
                                isReorderMode: true
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                        }
                        .onMove { source, destination in
                            store.reorderSlides(themeID: theme.id, from: source, to: destination)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: CGFloat(orderedSlides.count) * 120)
                    .environment(\.editMode, .constant(.active))
                } else {
                    ForEach(Array(orderedSlides.enumerated()), id: \.element.id) { index, slide in
                        SlideTimelineCell(
                            index: index + 1,
                            slide: slide,
                            isLast: index == orderedSlides.count - 1
                        )
                        .onTapGesture {
                            FeedbackManager.buttonTap()
                            viewModel.startEditingSlide(slide)
                        }
                        .contextMenu {
                            Button {
                                viewModel.startEditingSlide(slide)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                FeedbackManager.buttonTap()
                                store.deleteSlide(id: slide.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    private var exportSection: some View {
        GlassCard {
            VStack(spacing: 14) {
                SectionHeaderView(title: "Export Story", subtitle: "Share your completed story", icon: "square.and.arrow.up")

                HStack(spacing: 12) {
                    PrimaryButton(title: "PDF", icon: "doc.fill", isEnabled: !orderedSlides.isEmpty) {
                        viewModel.exportPDF(theme: theme, slides: orderedSlides, store: store)
                    }
                    PrimaryButton(title: "Text", icon: "text.quote", isEnabled: !orderedSlides.isEmpty, style: .accent) {
                        viewModel.exportText(theme: theme, slides: orderedSlides, store: store)
                    }
                }
            }
        }
    }
}
