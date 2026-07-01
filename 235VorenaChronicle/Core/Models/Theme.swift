import Foundation

struct Theme: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var emoji: String
    var description: String
    var reflectionPrompt: String
    var reflectionAnswer: String
    var slideOrder: [UUID]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        emoji: String,
        description: String,
        reflectionPrompt: String = Theme.defaultReflectionPrompt,
        reflectionAnswer: String = "",
        slideOrder: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.description = description
        self.reflectionPrompt = reflectionPrompt
        self.reflectionAnswer = reflectionAnswer
        self.slideOrder = slideOrder
        self.createdAt = createdAt
    }

    static let defaultReflectionPrompt = "What made this moment meaningful?"

    static let reflectionPromptOptions: [String] = [
        "What made this moment meaningful?",
        "What story does this collection tell?",
        "How did these moments change your perspective?",
        "What would you want to remember about this time?",
        "What connects these images together?"
    ]

    enum CodingKeys: String, CodingKey {
        case id, title, emoji, description, reflectionPrompt, reflectionAnswer, slideOrder, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        emoji = try container.decode(String.self, forKey: .emoji)
        description = try container.decode(String.self, forKey: .description)
        reflectionPrompt = try container.decodeIfPresent(String.self, forKey: .reflectionPrompt) ?? Theme.defaultReflectionPrompt
        reflectionAnswer = try container.decodeIfPresent(String.self, forKey: .reflectionAnswer) ?? ""
        slideOrder = try container.decodeIfPresent([UUID].self, forKey: .slideOrder) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
