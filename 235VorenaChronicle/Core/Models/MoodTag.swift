import Foundation

enum MoodTag: String, Codable, CaseIterable, Identifiable {
    case joyful
    case calm
    case nostalgic
    case energetic
    case thoughtful
    case peaceful

    var id: String { rawValue }

    var label: String {
        switch self {
        case .joyful: return "Joyful"
        case .calm: return "Calm"
        case .nostalgic: return "Nostalgic"
        case .energetic: return "Energetic"
        case .thoughtful: return "Thoughtful"
        case .peaceful: return "Peaceful"
        }
    }

    var iconName: String {
        switch self {
        case .joyful: return "face.smiling.fill"
        case .calm: return "leaf.fill"
        case .nostalgic: return "clock.fill"
        case .energetic: return "bolt.fill"
        case .thoughtful: return "brain.head.profile"
        case .peaceful: return "moon.stars.fill"
        }
    }

    var colorName: String {
        switch self {
        case .joyful: return "AppPrimary"
        case .calm: return "AppAccent"
        case .nostalgic: return "AppTextSecondary"
        case .energetic: return "AppPrimary"
        case .thoughtful: return "AppAccent"
        case .peaceful: return "AppTextSecondary"
        }
    }
}
