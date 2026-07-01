import SwiftUI

struct ThemeCuratorView: View {
    @EnvironmentObject private var store: AppStorage
    @StateObject private var viewModel = ThemeCuratorViewModel()
    @State private var searchText = ""

    private var filteredThemes: [Theme] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return store.themes }
        return store.themes.filter {
            $0.title.lowercased().contains(query) ||
            $0.description.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if store.themes.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            icon: "photo.stack.fill",
                            title: "No stories yet",
                            message: "Create your first visual story with photos, captions and mood tags.",
                            buttonTitle: "Create Story",
                            action: { viewModel.startCreating() }
                        )
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            statsStrip

                            if !searchText.isEmpty && filteredThemes.isEmpty {
                                Text("No stories match your search")
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredThemes) { theme in
                                        NavigationLink {
                                            StoryDetailView(theme: theme)
                                        } label: {
                                            StoryCardCell(
                                                theme: theme,
                                                slides: store.orderedSlides(for: theme)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .contextMenu {
                                            Button {
                                                viewModel.startEditing(theme)
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            Button(role: .destructive) {
                                                FeedbackManager.buttonTap()
                                                store.deleteTheme(id: theme.id)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .scrollContentBackground(.hidden)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(icon: "plus") {
                            viewModel.startCreating()
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 12)
                }

                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showSuccessCheckmark)
            }
            .navigationTitle("Visual Stories")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search stories")
            .sheet(isPresented: $viewModel.showEditor) {
                themeEditorSheet
            }
        }
    }

    private var statsStrip: some View {
        HStack(spacing: 10) {
            MetricTileView(value: "\(store.themes.count)", label: "Stories", icon: "books.vertical.fill")
            MetricTileView(value: "\(store.slides.count)", label: "Slides", icon: "photo.fill")
            MetricTileView(value: "\(store.totalExports)", label: "Exports", icon: "square.and.arrow.up")
        }
    }

    private var themeEditorSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Story Details", icon: "pencil.line")
                            TextField("Story title", text: $viewModel.title)
                                .padding(12)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .depthSurface(cornerRadius: 10, level: .flat)
                                .modifier(ShakeEffect(animatableData: viewModel.shakeTitle ? 1 : 0))
                            if !viewModel.titleError.isEmpty {
                                Text(viewModel.titleError)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            TextField("Brief description", text: $viewModel.description, axis: .vertical)
                                .lineLimit(3...5)
                                .padding(12)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .depthSurface(cornerRadius: 10, level: .flat)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Emoji Icon", icon: "face.smiling")
                            EmojiPickerView(selectedEmoji: $viewModel.emoji)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Reflection Prompt", subtitle: "Choose a question for this story", icon: "text.quote")
                            Picker("Prompt", selection: $viewModel.reflectionPrompt) {
                                ForEach(Theme.reflectionPromptOptions, id: \.self) { prompt in
                                    Text(prompt).tag(prompt)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AppAccent"))
                        }
                    }

                    PrimaryButton(title: "Save Story", icon: "checkmark") {
                        _ = viewModel.save(store: store)
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle(viewModel.editingTheme == nil ? "New Story" : "Edit Story")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.buttonTap()
                        viewModel.showEditor = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .presentationDetents([.large])
    }
}
