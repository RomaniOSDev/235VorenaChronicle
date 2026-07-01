import Foundation
import Combine

final class ThemeCuratorViewModel: ObservableObject {
    @Published var showEditor = false
    @Published var editingTheme: Theme?
    @Published var title = ""
    @Published var emoji = "🎨"
    @Published var description = ""
    @Published var reflectionPrompt = Theme.defaultReflectionPrompt
    @Published var titleError = ""
    @Published var shakeTitle = false
    @Published var showSuccessCheckmark = false

    func startCreating() {
        editingTheme = nil
        title = ""
        emoji = "🎨"
        description = ""
        reflectionPrompt = Theme.defaultReflectionPrompt
        titleError = ""
        showEditor = true
    }

    func startEditing(_ theme: Theme) {
        editingTheme = theme
        title = theme.title
        emoji = theme.emoji
        description = theme.description
        reflectionPrompt = theme.reflectionPrompt
        titleError = ""
        showEditor = true
    }

    func save(store: AppStorage) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            titleError = "Title is required"
            shakeTitle = true
            FeedbackManager.validationError()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.shakeTitle = false
            }
            return false
        }

        if var existing = editingTheme {
            existing.title = trimmedTitle
            existing.emoji = emoji
            existing.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.reflectionPrompt = reflectionPrompt
            store.updateTheme(existing)
        } else {
            let theme = Theme(
                title: trimmedTitle,
                emoji: emoji,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                reflectionPrompt: reflectionPrompt
            )
            store.addTheme(theme)
        }

        FeedbackManager.themeSaved()
        showEditor = false
        showSuccessCheckmark = true
        FeedbackManager.saveSuccess()
        return true
    }
}
