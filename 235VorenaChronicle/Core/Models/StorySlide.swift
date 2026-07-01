import Foundation

struct StorySlide: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var themeID: UUID
    var imageFileName: String?
    var imageSymbol: String
    var caption: String
    var moodTag: MoodTag
    var sortOrder: Int
    var date: Date

    init(
        id: UUID = UUID(),
        themeID: UUID,
        imageFileName: String? = nil,
        imageSymbol: String = "photo.fill",
        caption: String,
        moodTag: MoodTag = .thoughtful,
        sortOrder: Int = 0,
        date: Date = Date()
    ) {
        self.id = id
        self.themeID = themeID
        self.imageFileName = imageFileName
        self.imageSymbol = imageSymbol
        self.caption = caption
        self.moodTag = moodTag
        self.sortOrder = sortOrder
        self.date = date
    }

    var hasPhoto: Bool {
        imageFileName != nil
    }
}

private struct LegacyAnnotation: Codable {
    let id: UUID
    var imageID: String
    var imageSymbol: String
    var text: String
    var date: Date
}

enum StorySlideMigration {
    static func migrate(from data: Data, defaultThemeID: UUID?) -> [StorySlide] {
        if let slides = try? JSONDecoder().decode([StorySlide].self, from: data) {
            return slides
        }
        guard let legacy = try? JSONDecoder().decode([LegacyAnnotation].self, from: data),
              let themeID = defaultThemeID else { return [] }
        return legacy.enumerated().map { index, item in
            StorySlide(
                id: item.id,
                themeID: themeID,
                imageSymbol: item.imageSymbol,
                caption: item.text,
                sortOrder: index,
                date: item.date
            )
        }
    }
}
