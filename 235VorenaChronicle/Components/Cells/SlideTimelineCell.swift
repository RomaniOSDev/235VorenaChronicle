import SwiftUI

struct SlideTimelineCell: View {
    let index: Int
    let slide: StorySlide
    let isLast: Bool
    var isReorderMode: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.35), Color("AppBackground")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    Text("\(index)")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }

                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppAccent").opacity(0.5), Color("AppAccent").opacity(0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 32)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    PhotoThumbnailView(slide: slide, size: 80, showBorder: true, cornerRadius: 14)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(slide.caption)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(3)

                        MoodChipView(mood: slide.moodTag, compact: true)

                        Text(slide.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Spacer(minLength: 0)

                    if isReorderMode {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(Color("AppTextSecondary"))
                            .padding(8)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .depthSurface(cornerRadius: 14, level: .flat)
        }
        .padding(.bottom, isLast ? 0 : 4)
    }
}

struct MoodChipView: View {
    let mood: MoodTag
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: mood.iconName)
                .font(compact ? .caption2 : .caption)
            Text(mood.label)
                .font(compact ? .caption2 : .caption)
                .lineLimit(1)
        }
        .foregroundStyle(Color("AppTextPrimary"))
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(mood.colorName).opacity(0.45), Color(mood.colorName).opacity(0.25)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            Capsule()
                .stroke(Color("AppTextPrimary").opacity(0.08), lineWidth: 0.5)
        )
    }
}
