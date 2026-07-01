import SwiftUI

struct ExportCardPreviewView: View {
    let theme: Theme
    let slides: [StorySlide]
    let layout: CardLayout
    let showCaptions: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Text(theme.emoji)
                    .font(.title)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary").opacity(0.3), Color("AppBackground")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.title)
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(slides.count) moments")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: layout.columns), spacing: 8) {
                ForEach(Array(slides.prefix(layout.maxPhotos).enumerated()), id: \.element.id) { _, slide in
                    VStack(spacing: 6) {
                        PhotoThumbnailView(
                            slide: slide,
                            size: layout == .single ? 200 : 100,
                            showBorder: true,
                            cornerRadius: 12
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: layout == .single ? 200 : 100)
                        .clipped()

                        if showCaptions {
                            Text(slide.caption)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }

            if !theme.reflectionAnswer.isEmpty && showCaptions {
                HStack(spacing: 6) {
                    Image(systemName: "text.quote")
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Text(theme.reflectionAnswer)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(DepthStyle.tileGradient)
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(DepthStyle.cardStroke, lineWidth: 1.5)
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DepthStyle.innerHighlight)
                .frame(height: 50)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .compositingGroup()
        .shadow(color: Color("AppPrimary").opacity(0.3), radius: 10, y: 5)
    }
}
