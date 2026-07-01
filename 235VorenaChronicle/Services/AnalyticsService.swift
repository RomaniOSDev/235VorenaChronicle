import Foundation

struct ThemeFrequencyItem: Identifiable {
    let id: UUID
    let title: String
    let emoji: String
    let slideCount: Int
}

struct MoodFrequencyItem: Identifiable {
    let id: String
    let mood: MoodTag
    let count: Int
}

struct WeeklyDigestData {
    let slidesAdded: Int
    let themesUpdated: Int
    let topMood: MoodTag?
    let exportsCount: Int
    let activeDays: Int
}

struct SmartGroup: Identifiable {
    let id: String
    let title: String
    let iconName: String
    let slides: [StorySlide]
}

enum AnalyticsService {
    static func themeFrequency(themes: [Theme], slides: [StorySlide]) -> [ThemeFrequencyItem] {
        themes.map { theme in
            let count = slides.filter { $0.themeID == theme.id }.count
            return ThemeFrequencyItem(id: theme.id, title: theme.title, emoji: theme.emoji, slideCount: count)
        }
        .sorted { $0.slideCount > $1.slideCount }
    }

    static func topMoodTags(slides: [StorySlide]) -> [MoodFrequencyItem] {
        var counts: [MoodTag: Int] = [:]
        for slide in slides {
            counts[slide.moodTag, default: 0] += 1
        }
        return counts.map { MoodFrequencyItem(id: $0.key.rawValue, mood: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    static func activityByWeekday(slides: [StorySlide]) -> [Int] {
        var result = Array(repeating: 0, count: 7)
        let calendar = Calendar.current
        for slide in slides {
            let weekday = calendar.component(.weekday, from: slide.date)
            let index = (weekday + 5) % 7
            result[index] += 1
        }
        return result
    }

    static func weeklyDigest(
        slides: [StorySlide],
        themes: [Theme],
        totalExports: Int
    ) -> WeeklyDigestData {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        let recentSlides = slides.filter { $0.date >= weekAgo }
        let recentThemes = themes.filter { $0.createdAt >= weekAgo }

        var activeDaysSet = Set<String>()
        for slide in recentSlides {
            let day = calendar.startOfDay(for: slide.date)
            activeDaysSet.insert(day.description)
        }

        let moodCounts = topMoodTags(slides: recentSlides)
        let topMood = moodCounts.first?.mood

        return WeeklyDigestData(
            slidesAdded: recentSlides.count,
            themesUpdated: recentThemes.count,
            topMood: topMood,
            exportsCount: totalExports,
            activeDays: activeDaysSet.count
        )
    }

    static func smartGroups(slides: [StorySlide], themes: [Theme]) -> [SmartGroup] {
        var groups: [SmartGroup] = []

        let moodGroups = Dictionary(grouping: slides, by: { $0.moodTag })
        for mood in MoodTag.allCases {
            if let moodSlides = moodGroups[mood], !moodSlides.isEmpty {
                groups.append(SmartGroup(
                    id: "mood_\(mood.rawValue)",
                    title: "\(mood.label) Moments",
                    iconName: mood.iconName,
                    slides: moodSlides.sorted { $0.date > $1.date }
                ))
            }
        }

        for theme in themes {
            let themeSlides = slides.filter { $0.themeID == theme.id }
            if !themeSlides.isEmpty {
                groups.append(SmartGroup(
                    id: "theme_\(theme.id.uuidString)",
                    title: "\(theme.emoji) \(theme.title)",
                    iconName: "folder.fill",
                    slides: themeSlides.sorted { $0.sortOrder < $1.sortOrder }
                ))
            }
        }

        return groups
    }

    static let weekdayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
}
