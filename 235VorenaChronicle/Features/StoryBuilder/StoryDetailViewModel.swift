import Foundation
import Combine

final class StoryDetailViewModel: ObservableObject {
    @Published var editingSlide: StorySlide?
    @Published var isEditingOrder = false
    @Published var showExportSheet = false
    @Published var exportItems: [Any] = []
    @Published var showSuccessCheckmark = false

    func startAddingSlide(themeID: UUID) {
        editingSlide = StorySlide(themeID: themeID, caption: "")
    }

    func startEditingSlide(_ slide: StorySlide) {
        editingSlide = slide
    }

    func exportPDF(theme: Theme, slides: [StorySlide], store: AppStorage) {
        guard let url = StoryExportService.exportPDF(theme: theme, slides: slides) else { return }
        exportItems = [url]
        showExportSheet = true
        store.recordExport()
        FeedbackManager.saveSuccess()
        showSuccessCheckmark = true
    }

    func exportText(theme: Theme, slides: [StorySlide], store: AppStorage) {
        let text = StoryExportService.exportText(theme: theme, slides: slides)
        exportItems = [text]
        showExportSheet = true
        store.recordExport()
        FeedbackManager.saveSuccess()
        showSuccessCheckmark = true
    }
}
