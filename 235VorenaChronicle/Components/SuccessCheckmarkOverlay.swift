import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                    }
                }
        }
    }
}
