import SwiftUI

struct MoodTagPicker: View {
    @Binding var selectedMood: MoodTag

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MoodTag.allCases) { mood in
                    Button {
                        FeedbackManager.buttonTap()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedMood = mood
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: mood.iconName)
                                .font(.caption)
                            Text(mood.label)
                                .font(.caption.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .foregroundStyle(selectedMood == mood ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .background(
                            Capsule()
                                .fill(selectedMood == mood ? Color(mood.colorName).opacity(0.45) : Color("AppBackground").opacity(0.6))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedMood == mood ? Color(mood.colorName) : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 2)
        }
    }
}
