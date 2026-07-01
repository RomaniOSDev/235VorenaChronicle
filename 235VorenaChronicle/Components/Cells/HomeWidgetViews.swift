import SwiftUI

private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<AppTab>? = nil
}

extension EnvironmentValues {
    var selectedAppTab: Binding<AppTab>? {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

struct HomeStatWidget: View {
    let title: String
    let value: String
    let icon: String
    var trend: String?
    var accent: Color = Color("AppPrimary")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline.bold())
                    .foregroundStyle(accent)
                    .frame(width: 32, height: 32)
                    .background(accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Spacer()
                if let trend {
                    Text(trend)
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppAccent"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color("AppAccent").opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Text(value)
                .font(.title.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .depthCard(cornerRadius: 18, level: .raised, padding: 14)
    }
}

struct HomeQuickActionWidget: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.3), Color("AppBackground")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(Color("AppAccent"))
                }
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 88)
            .depthCard(cornerRadius: 16, level: .flat, padding: 12)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct HomeMomentWidget: View {
    let slide: StorySlide
    let theme: Theme?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PhotoThumbnailView(slide: slide, size: 120, showBorder: true, cornerRadius: 14)
                .frame(width: 120, height: 120)

            Text(slide.caption)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)

            if let theme {
                HStack(spacing: 4) {
                    Text(theme.emoji)
                        .font(.caption2)
                    Text(theme.title)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                .frame(width: 120, alignment: .leading)
            }

            MoodChipView(mood: slide.moodTag, compact: true)
        }
        .depthCard(cornerRadius: 18, level: .raised, padding: 10)
    }
}

struct HomeStoryWidget: View {
    let theme: Theme
    let slides: [StorySlide]

    var body: some View {
        HStack(spacing: 14) {
            if let first = slides.first {
                PhotoThumbnailView(slide: first, size: 64, showBorder: true, cornerRadius: 12)
            } else {
                Image("HomeWidgetEmpty")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(theme.emoji)
                    Text(theme.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                }
                Text("\(slides.count) slides")
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                if !theme.reflectionAnswer.isEmpty {
                    Text(theme.reflectionAnswer)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(Color("AppPrimary"))
        }
        .depthCard(cornerRadius: 16, level: .raised, padding: 14)
    }
}

struct HomeWeekWidget: View {
    let digest: WeeklyDigestData
    let topMood: MoodTag?

    var body: some View {
        HStack(spacing: 16) {
            Image("HomeWidgetEmpty")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color("AppAccent").opacity(0.3), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("This Week")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 12) {
                    Label("\(digest.slidesAdded)", systemImage: "photo")
                    Label("\(digest.activeDays)d", systemImage: "flame.fill")
                }
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                if let topMood {
                    MoodChipView(mood: topMood, compact: true)
                }
            }

            Spacer()
        }
        .depthCard(cornerRadius: 18, level: .raised, padding: 14)
    }
}
