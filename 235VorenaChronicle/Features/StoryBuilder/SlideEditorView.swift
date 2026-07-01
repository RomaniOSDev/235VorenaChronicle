import SwiftUI
import PhotosUI

struct SlideEditorView: View {
    @EnvironmentObject private var store: AppStorage
    @Environment(\.dismiss) private var dismiss

    @State var slide: StorySlide
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var captionError = ""
    @State private var shakeCaption = false
    @State private var previewImage: UIImage?

    var isNew: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    photoSection

                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeaderView(title: "Mood", subtitle: "How does this moment feel?", icon: "face.smiling")
                            MoodTagPicker(selectedMood: $slide.moodTag)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Caption", subtitle: "Describe this moment", icon: "text.bubble")
                            TextField("Write a caption for this moment...", text: $slide.caption, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(14)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .depthSurface(cornerRadius: 12, level: .flat)
                                .modifier(ShakeEffect(animatableData: shakeCaption ? 1 : 0))

                            if !captionError.isEmpty {
                                Text(captionError)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    PrimaryButton(title: isNew ? "Add to Story" : "Save Slide", icon: "checkmark") {
                        saveSlide()
                    }
                }
                .padding(16)
            }
            .background(Color("AppBackground"))
            .navigationTitle(isNew ? "New Slide" : "Edit Slide")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenStyle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.buttonTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                        previewImage = UIImage(data: data)
                    }
                }
            }
        }
    }

    private var photoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(DepthStyle.cardGradient)
                    .frame(width: 220, height: 220)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(DepthStyle.cardStroke, lineWidth: 2)
                    )
                    .compositingGroup()
                    .shadow(color: Color("AppBackground").opacity(0.25), radius: 8, y: 4)

                Group {
                    if let previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFill()
                    } else if let fileName = slide.imageFileName,
                              let uiImage = ImageStorageService.loadImage(fileName: fileName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 44))
                                .foregroundStyle(Color("AppTextSecondary"))
                            Text("No photo selected")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                    Text("Choose Photo")
                        .font(.subheadline.bold())
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .depthButton(cornerRadius: 24, gradient: DepthStyle.buttonGradient)
            }
        }
    }

    private func saveSlide() {
        let trimmed = slide.caption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            captionError = "Caption is required"
            shakeCaption = true
            FeedbackManager.validationError()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeCaption = false
            }
            return
        }
        slide.caption = trimmed

        if isNew {
            store.addSlide(slide, imageData: photoData)
        } else {
            store.updateSlide(slide, imageData: photoData)
        }

        FeedbackManager.annotationSaved()
        FeedbackManager.saveSuccess()
        dismiss()
    }
}
