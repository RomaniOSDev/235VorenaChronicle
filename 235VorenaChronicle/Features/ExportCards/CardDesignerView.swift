import SwiftUI

struct CardDesignerView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var selectedThemeID: UUID?
    @State private var selectedLayout: CardLayout = .single
    @State private var showCaptions = true
    @State private var showShareSheet = false
    @State private var exportedImage: UIImage?
    @State private var showSuccessCheckmark = false

    private var selectedTheme: Theme? {
        guard let id = selectedThemeID else { return store.themes.first }
        return store.themes.first { $0.id == id }
    }

    private var slides: [StorySlide] {
        guard let theme = selectedTheme else { return [] }
        return store.orderedSlides(for: theme)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        if store.themes.isEmpty {
                            EmptyStateView(
                                icon: "rectangle.portrait.on.rectangle.portrait.angled",
                                title: "Create a story first",
                                message: "Build a visual story, then design a beautiful export card."
                            )
                        } else {
                            designerControls
                            previewSection
                            PrimaryButton(
                                title: "Export Card as PNG",
                                icon: "square.and.arrow.up",
                                isEnabled: !slides.isEmpty
                            ) {
                                exportCard()
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }

                SuccessCheckmarkOverlay(isVisible: $showSuccessCheckmark)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSuccessCheckmark)
            }
            .navigationTitle("Card Designer")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .sheet(isPresented: $showShareSheet) {
                if let image = exportedImage {
                    ShareSheet(items: [image])
                }
            }
            .onAppear {
                syncSelectedThemeID()
            }
            .onChange(of: store.themes) { _ in
                syncSelectedThemeID()
            }
        }
    }

    private var themePickerSelection: Binding<UUID> {
        Binding(
            get: {
                if let id = selectedThemeID,
                   store.themes.contains(where: { $0.id == id }) {
                    return id
                }
                return store.themes.first!.id
            },
            set: { selectedThemeID = $0 }
        )
    }

    private func syncSelectedThemeID() {
        if let id = selectedThemeID,
           store.themes.contains(where: { $0.id == id }) {
            return
        }
        selectedThemeID = store.themes.first?.id
    }

    private var designerControls: some View {
        GlassCard {
            VStack(spacing: 18) {
                SectionHeaderView(title: "Design Options", subtitle: "Customize your export card", icon: "slider.horizontal.3")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Story")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                    Picker("Theme", selection: themePickerSelection) {
                        ForEach(store.themes) { theme in
                            Text("\(theme.emoji) \(theme.title)").tag(theme.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color("AppAccent"))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .depthSurface(cornerRadius: 10, level: .flat)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Layout")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                    HStack(spacing: 10) {
                        ForEach(CardLayout.allCases) { layout in
                            LayoutOptionCell(
                                layout: layout,
                                isSelected: selectedLayout == layout
                            ) {
                                FeedbackManager.buttonTap()
                                selectedLayout = layout
                            }
                        }
                    }
                }

                Toggle(isOn: $showCaptions) {
                    HStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .foregroundStyle(Color("AppPrimary"))
                        Text("Show Captions")
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
                .tint(Color("AppPrimary"))
            }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Live Preview", icon: "eye.fill")
                .padding(.horizontal, 4)

            if let theme = selectedTheme {
                ExportCardPreviewView(
                    theme: theme,
                    slides: slides,
                    layout: selectedLayout,
                    showCaptions: showCaptions
                )
            }
        }
    }

    private func exportCard() {
        guard let theme = selectedTheme else { return }

        let cardView = ExportCardPreviewView(
            theme: theme,
            slides: slides,
            layout: selectedLayout,
            showCaptions: showCaptions
        )
        .frame(width: 360)

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = UIScreen.main.scale

        if let uiImage = renderer.uiImage {
            exportedImage = uiImage
            showShareSheet = true
            store.recordExport()
            FeedbackManager.saveSuccess()
            showSuccessCheckmark = true
        }
    }
}
