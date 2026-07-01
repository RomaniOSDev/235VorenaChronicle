import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStorage
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "OnboardingStories",
            icon: "photo.stack.fill",
            badge: "Step 1",
            headline: "Build Visual Stories",
            description: "Create themed stories with real photos, captions and mood tags."
        ),
        OnboardingPage(
            imageName: "OnboardingReflect",
            icon: "arrow.up.arrow.down.circle.fill",
            badge: "Step 2",
            headline: "Reflect & Reorder",
            description: "Answer reflection prompts and drag slides into the perfect order."
        ),
        OnboardingPage(
            imageName: "OnboardingExport",
            icon: "square.and.arrow.up.circle.fill",
            badge: "Step 3",
            headline: "Export & Share",
            description: "Export your story as PDF, text, or a beautiful share card."
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                pageIndicator
                    .padding(.bottom, 12)

                PrimaryButton(
                    title: currentPage < pages.count - 1 ? "Next" : "Get Started",
                    icon: currentPage < pages.count - 1 ? "arrow.right" : "checkmark"
                ) {
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        store.completeOnboarding()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AnyShapeStyle(DepthStyle.buttonGradient)
                            : AnyShapeStyle(Color("AppTextSecondary").opacity(0.3))
                    )
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private func onboardingPage(page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 0) {
            OnboardingHeroImage(
                imageName: page.imageName,
                icon: page.icon,
                isActive: currentPage == index
            )
            .padding(.horizontal, 24)
            .padding(.top, 8)

            VStack(spacing: 16) {
                Text(page.badge)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color("AppAccent").opacity(0.18))
                            .overlay(
                                Capsule()
                                    .stroke(Color("AppAccent").opacity(0.35), lineWidth: 0.5)
                            )
                    )

                Text(page.headline)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
            .depthCard(cornerRadius: 22, level: .raised, padding: 22)
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer(minLength: 0)

            if currentPage < pages.count - 1 {
                Button {
                    FeedbackManager.buttonTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .buttonStyle(PressableButtonStyle())
            } else {
                Color.clear.frame(height: 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OnboardingPage {
    let imageName: String
    let icon: String
    let badge: String
    let headline: String
    let description: String
}

private struct OnboardingHeroImage: View {
    let imageName: String
    let icon: String
    let isActive: Bool

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.05),
                    Color("AppBackground").opacity(0.55),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(DepthStyle.buttonGradient)
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(DepthStyle.innerHighlight)
                            .frame(height: 22)
                            .allowsHitTesting(false)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .compositingGroup()
                    .shadow(color: Color("AppPrimary").opacity(0.35), radius: 6, y: 3)

                Spacer()
            }
            .padding(18)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(DepthStyle.cardStroke, lineWidth: 1.5)
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(DepthStyle.innerHighlight)
                .frame(height: 60)
                .allowsHitTesting(false)
        }
        .compositingGroup()
        .shadow(
            color: Color("AppPrimary").opacity(DepthLevel.hero.shadowOpacity),
            radius: DepthLevel.hero.shadowRadius,
            y: DepthLevel.hero.shadowY
        )
        .scaleEffect(appeared ? 1 : 0.94)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                appeared = true
            }
        }
        .onChange(of: isActive) { active in
            guard active else { return }
            appeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                appeared = true
            }
        }
    }
}
