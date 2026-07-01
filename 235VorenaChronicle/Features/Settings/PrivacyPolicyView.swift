import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownContent = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    GlassCard {
                        if markdownContent.isEmpty {
                            Text("Privacy policy not found.")
                                .foregroundStyle(Color("AppTextSecondary"))
                        } else if let attributed = try? AttributedString(markdown: markdownContent) {
                            Text(attributed)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .tint(Color("AppPrimary"))
                        } else {
                            Text(markdownContent)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackManager.buttonTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
            .onAppear {
                loadPrivacyPolicy()
            }
        }
    }

    private func loadPrivacyPolicy() {
        if let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            markdownContent = content
        }
    }
}
