import SwiftUI

struct PhotoThumbnailView: View {
    let slide: StorySlide
    var size: CGFloat = 64
    var showBorder: Bool = false
    var cornerRadius: CGFloat = 10

    var body: some View {
        Group {
            if let fileName = slide.imageFileName,
               let uiImage = ImageStorageService.loadImage(fileName: fileName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [Color("AppBackground"), Color("AppSurface")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: slide.imageSymbol)
                        .font(.title2)
                        .foregroundStyle(Color("AppAccent").opacity(0.7))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            if showBorder {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DepthStyle.cardStroke, lineWidth: 1)
            }
        }
        .overlay(alignment: .top) {
            if showBorder {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DepthStyle.innerHighlight)
                    .frame(height: size * 0.35)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
