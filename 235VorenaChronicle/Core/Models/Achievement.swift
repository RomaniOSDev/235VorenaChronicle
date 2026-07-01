import Foundation

struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [Achievement] = [
        Achievement(id: "first_step", title: "First Step", description: "Added the first note to a photo.", iconName: "star.fill"),
        Achievement(id: "note_collector", title: "Note Collector", description: "Attached notes to 10 photos.", iconName: "note.text"),
        Achievement(id: "gallery_curator", title: "Gallery Curator", description: "Created a curated gallery with at least 5 annotated photos.", iconName: "photo.on.rectangle.angled"),
        Achievement(id: "insight_seeker", title: "Insight Seeker", description: "Viewed analytics about media usage patterns 5 times.", iconName: "chart.bar.fill"),
        Achievement(id: "power_user", title: "Power User", description: "Reached 50 items.", iconName: "bolt.fill"),
        Achievement(id: "active_user", title: "Active User", description: "Completed 10 sessions.", iconName: "flame.fill"),
        Achievement(id: "dedicated_user", title: "Dedicated User", description: "Completed 50 sessions.", iconName: "crown.fill"),
        Achievement(id: "three_day_streak", title: "Three-Day Streak", description: "Used the app 3 days in a row.", iconName: "calendar")
    ]
}
