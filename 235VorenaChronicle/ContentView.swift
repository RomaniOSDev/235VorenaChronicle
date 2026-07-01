import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStorage()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(store)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
