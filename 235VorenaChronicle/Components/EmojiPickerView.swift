import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String

    private let emojis = ["🎨", "📸", "🌅", "🏙️", "🌿", "✈️", "🎭", "📚", "⭐", "💡", "🎬", "🖼️", "🌊", "🔥", "💎", "🎵"]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    FeedbackManager.buttonTap()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedEmoji = emoji
                    }
                } label: {
                    Text(emoji)
                        .font(.largeTitle)
                        .frame(width: 58, height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedEmoji == emoji ? Color("AppPrimary").opacity(0.25) : Color("AppBackground").opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selectedEmoji == emoji ? Color("AppPrimary") : Color.clear, lineWidth: 2)
                        )
                        .scaleEffect(selectedEmoji == emoji ? 1.08 : 1.0)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}
