import SwiftUI

struct AchievementBannerView: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -120

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundStyle(Color("AppAccent"))

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            Spacer()
        }
        .depthCard(cornerRadius: 12, level: .floating, padding: 16)
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            FeedbackManager.achievementUnlocked()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -120
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}
