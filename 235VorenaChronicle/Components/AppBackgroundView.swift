import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Radial gradients instead of blur — much cheaper on GPU
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color("AppPrimary").opacity(0.14), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 280)
                .offset(x: -100, y: -220)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color("AppAccent").opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 240)
                .offset(x: 130, y: 320)

            dotPattern
        }
        .ignoresSafeArea()
        .drawingGroup(opaque: false)
    }

    private var dotPattern: some View {
        Canvas { context, size in
            let spacing: CGFloat = 44
            let dotSize: CGFloat = 1.4
            for x in stride(from: 0, through: size.width, by: spacing) {
                for y in stride(from: 0, through: size.height, by: spacing) {
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    context.fill(Path(ellipseIn: rect), with: .color(Color("AppTextSecondary").opacity(0.05)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ScreenToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppBackgroundView().ignoresSafeArea())
            .toolbarBackground(
                LinearGradient(
                    colors: [Color("AppSurface"), Color("AppSurface").opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func appScreenStyle() -> some View {
        modifier(ScreenToolbarModifier())
    }
}
