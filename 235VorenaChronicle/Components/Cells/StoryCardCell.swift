import SwiftUI

struct StoryCardCell: View {
    let theme: Theme
    let slides: [StorySlide]
    var onEdit: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.3), Color("AppBackground")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color("AppPrimary").opacity(0.25), lineWidth: 0.5)
                        )
                    Text(theme.emoji)
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(theme.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if !theme.description.isEmpty {
                        Text(theme.description)
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                    }

                    HStack(spacing: 10) {
                        Label("\(slides.count)", systemImage: "photo.on.rectangle")
                        if !theme.reflectionAnswer.isEmpty {
                            Label("Reflection", systemImage: "text.quote")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(8)
                    .background(
                        Circle()
                            .fill(DepthStyle.tileGradient)
                    )
            }

            if !slides.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(slides.prefix(5)) { slide in
                            PhotoThumbnailView(slide: slide, size: 52, showBorder: true)
                        }
                        if slides.count > 5 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(DepthStyle.tileGradient)
                                    .frame(width: 52, height: 52)
                                Text("+\(slides.count - 5)")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color("AppAccent"))
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                    Text("Tap to add your first slide")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .depthCard(cornerRadius: 18, level: .raised, padding: 16)
    }
}
