import SwiftUI

struct InsightMenuCell: View {
    let title: String
    let subtitle: String
    let icon: String
    var badge: String?

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.35), Color("AppBackground")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 0.5)
                    )
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let badge {
                        Text(badge)
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(DepthStyle.buttonGradient)
                            )
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .font(.title3)
                .foregroundStyle(Color("AppPrimary").opacity(0.85))
        }
        .depthCard(cornerRadius: 18, level: .raised, padding: 16)
    }
}

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(isDestructive ? Color.red : Color("AppPrimary"))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    (isDestructive ? Color.red : Color("AppPrimary")).opacity(0.18),
                                    Color("AppBackground").opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            Text(title)
                .font(.body)
                .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

struct AchievementBadgeCell: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                isUnlocked ? Color("AppPrimary").opacity(0.3) : Color("AppBackground"),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 28
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.35))
            }

            Text(achievement.title)
                .font(.caption.bold())
                .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(3)
                .multilineTextAlignment(.center)

            if isUnlocked {
                Text("Unlocked")
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color("AppPrimary").opacity(0.25)))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150)
        .depthSurface(cornerRadius: 16, level: isUnlocked ? .raised : .flat)
        .opacity(isUnlocked ? 1 : 0.65)
    }
}

struct DigestStatCell: View {
    let value: String
    let label: String
    let icon: String
    var trend: String?

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.22), Color("AppBackground").opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer()

            if let trend {
                Text(trend)
                    .font(.caption2)
                    .foregroundStyle(Color("AppAccent"))
            }
        }
        .depthCard(cornerRadius: 16, level: .raised, padding: 16)
    }
}

struct GroupCollectionCell: View {
    let group: SmartGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: group.iconName)
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(width: 28, height: 28)
                    .background(Color("AppPrimary").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text(group.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Spacer()
                Text("\(group.slides.count)")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppAccent").opacity(0.35), Color("AppPrimary").opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(group.slides.prefix(10)) { slide in
                        VStack(spacing: 4) {
                            PhotoThumbnailView(slide: slide, size: 64, showBorder: true)
                            Text(slide.caption)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(1)
                                .frame(width: 64)
                        }
                    }
                }
            }
        }
        .depthCard(cornerRadius: 18, level: .raised, padding: 16)
    }
}

struct LayoutOptionCell: View {
    let layout: CardLayout
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                layoutPreview
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(DepthStyle.tileGradient)
                    )

                Text(layout.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.25), Color("AppSurface")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            : DepthStyle.cardGradient
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color("AppPrimary") : Color("AppAccent").opacity(0.1), lineWidth: isSelected ? 2 : 0.5)
            )
            .compositingGroup()
            .shadow(color: Color("AppBackground").opacity(isSelected ? 0.3 : 0), radius: isSelected ? 6 : 0, y: 3)
        }
        .buttonStyle(PressableButtonStyle())
    }

    @ViewBuilder
    private var layoutPreview: some View {
        switch layout {
        case .single:
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color("AppAccent"), lineWidth: 1.5)
                .padding(12)
        case .dual:
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 3).stroke(Color("AppAccent"), lineWidth: 1)
                RoundedRectangle(cornerRadius: 3).stroke(Color("AppAccent"), lineWidth: 1)
            }
            .padding(12)
        case .quad:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color("AppAccent"), lineWidth: 1)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(10)
        }
    }
}
