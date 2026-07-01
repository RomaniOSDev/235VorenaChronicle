import Foundation
import Combine

final class AppStorage: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let themes = "themes"
        static let storySlides = "storySlides"
        static let annotations = "annotations"
        static let favourites = "favourites"
        static let lastViewedCollectionID = "lastViewedCollectionID"
        static let searchQueries = "searchQueries"
        static let usageViews = "usageViews"
        static let totalExports = "totalExports"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var sessionTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var themes: [Theme] {
        didSet { saveCodable(themes, key: Keys.themes) }
    }

    @Published var slides: [StorySlide] {
        didSet { saveCodable(slides, key: Keys.storySlides) }
    }

    @Published var favourites: [String] {
        didSet { defaults.set(favourites, forKey: Keys.favourites) }
    }

    @Published var lastViewedCollectionID: String {
        didSet { defaults.set(lastViewedCollectionID, forKey: Keys.lastViewedCollectionID) }
    }

    @Published var searchQueries: [String] {
        didSet { defaults.set(searchQueries, forKey: Keys.searchQueries) }
    }

    @Published var usageViews: Int {
        didSet { defaults.set(usageViews, forKey: Keys.usageViews) }
    }

    @Published var totalExports: Int {
        didSet { defaults.set(totalExports, forKey: Keys.totalExports) }
    }

    @Published var newlyUnlockedAchievement: Achievement?

    var itemsAdded: Int { slides.count }
    var entriesWritten: Int { totalSessionsCompleted }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, defaults: defaults)
        let loadedThemes: [Theme] = Self.loadCodable(key: Keys.themes, defaults: defaults) ?? []
        themes = loadedThemes
        slides = Self.loadSlides(defaults: defaults, themes: loadedThemes)
        favourites = defaults.stringArray(forKey: Keys.favourites) ?? []
        lastViewedCollectionID = defaults.string(forKey: Keys.lastViewedCollectionID) ?? ""
        searchQueries = defaults.stringArray(forKey: Keys.searchQueries) ?? []
        usageViews = defaults.integer(forKey: Keys.usageViews)
        totalExports = defaults.integer(forKey: Keys.totalExports)

        NotificationCenter.default.publisher(for: .dataReset)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func recordSession() {
        totalSessionsCompleted += 1
        updateStreak()
        checkAchievements()
    }

    func recordUsageView() {
        usageViews += 1
        checkAchievements()
    }

    func recordExport() {
        totalExports += 1
        recordSession()
    }

    func addTheme(_ theme: Theme) {
        themes.append(theme)
        recordSession()
    }

    func updateTheme(_ theme: Theme) {
        if let index = themes.firstIndex(where: { $0.id == theme.id }) {
            themes[index] = theme
            recordSession()
        }
    }

    func deleteTheme(id: UUID) {
        let themeSlides = slides.filter { $0.themeID == id }
        for slide in themeSlides {
            deleteSlide(id: slide.id, removeFiles: true)
        }
        themes.removeAll { $0.id == id }
    }

    func orderedSlides(for theme: Theme) -> [StorySlide] {
        let themeSlides = slides.filter { $0.themeID == theme.id }
        if theme.slideOrder.isEmpty {
            return themeSlides.sorted { $0.sortOrder < $1.sortOrder }
        }
        var ordered: [StorySlide] = []
        for slideID in theme.slideOrder {
            if let slide = themeSlides.first(where: { $0.id == slideID }) {
                ordered.append(slide)
            }
        }
        let unordered = themeSlides.filter { !theme.slideOrder.contains($0.id) }
        return ordered + unordered.sorted { $0.sortOrder < $1.sortOrder }
    }

    func addSlide(_ slide: StorySlide, imageData: Data? = nil) {
        var newSlide = slide
        if let data = imageData, let fileName = ImageStorageService.saveImage(data) {
            newSlide.imageFileName = fileName
        }
        slides.append(newSlide)
        appendSlideToThemeOrder(slideID: newSlide.id, themeID: newSlide.themeID)
        recordSession()
    }

    func updateSlide(_ slide: StorySlide, imageData: Data? = nil) {
        guard let index = slides.firstIndex(where: { $0.id == slide.id }) else { return }
        var updated = slide
        if let data = imageData {
            if let oldFile = slides[index].imageFileName {
                ImageStorageService.deleteImage(fileName: oldFile)
            }
            updated.imageFileName = ImageStorageService.saveImage(data)
        }
        slides[index] = updated
        recordSession()
    }

    func deleteSlide(id: UUID, removeFiles: Bool = true) {
        if removeFiles, let slide = slides.first(where: { $0.id == id }),
           let fileName = slide.imageFileName {
            ImageStorageService.deleteImage(fileName: fileName)
        }
        slides.removeAll { $0.id == id }
        for index in themes.indices {
            themes[index].slideOrder.removeAll { $0 == id }
        }
    }

    func reorderSlides(themeID: UUID, from source: IndexSet, to destination: Int) {
        guard let themeIndex = themes.firstIndex(where: { $0.id == themeID }) else { return }
        var order = orderedSlides(for: themes[themeIndex]).map(\.id)
        order.reorder(from: source, to: destination)
        themes[themeIndex].slideOrder = order
        for (index, slideID) in order.enumerated() {
            if let slideIndex = slides.firstIndex(where: { $0.id == slideID }) {
                slides[slideIndex].sortOrder = index
            }
        }
        recordSession()
    }

    func toggleFavourite(collectionID: String) {
        if favourites.contains(collectionID) {
            favourites.removeAll { $0 == collectionID }
        } else {
            favourites.append(collectionID)
        }
    }

    func isFavourite(_ collectionID: String) -> Bool {
        favourites.contains(collectionID)
    }

    func recordSearchQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !searchQueries.contains(trimmed) {
            searchQueries.append(trimmed)
        }
    }

    func viewCollection(id: String) {
        lastViewedCollectionID = id
        recordSession()
    }

    func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.totalMinutesUsed += 1
            }
        }
    }

    func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }

    func resetAllData() {
        ImageStorageService.deleteAllImages()
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func checkAchievements() {
        let conditions: [(String, Bool)] = [
            ("first_step", itemsAdded >= 1),
            ("note_collector", itemsAdded >= 10),
            ("gallery_curator", themes.filter { orderedSlides(for: $0).count >= 5 }.count >= 1),
            ("insight_seeker", usageViews >= 5),
            ("power_user", itemsAdded >= 50),
            ("active_user", entriesWritten >= 10),
            ("dedicated_user", entriesWritten >= 50),
            ("three_day_streak", streakDays >= 3)
        ]

        for (id, met) in conditions where met && !isAchievementUnlocked(id) {
            unlockAchievement(id: id)
        }
    }

    private func unlockAchievement(id: String) {
        achievementsUnlocked[id] = Date()
        if let achievement = Achievement.all.first(where: { $0.id == id }) {
            newlyUnlockedAchievement = achievement
        }
    }

    func clearNewlyUnlockedAchievement() {
        newlyUnlockedAchievement = nil
    }

    private func appendSlideToThemeOrder(slideID: UUID, themeID: UUID) {
        guard let index = themes.firstIndex(where: { $0.id == themeID }) else { return }
        themes[index].slideOrder.append(slideID)
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 0 {
                return
            } else if diff == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = Date()
        checkAchievements()
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, defaults: defaults)
        let loadedThemes: [Theme] = Self.loadCodable(key: Keys.themes, defaults: defaults) ?? []
        themes = loadedThemes
        slides = Self.loadSlides(defaults: defaults, themes: loadedThemes)
        favourites = defaults.stringArray(forKey: Keys.favourites) ?? []
        lastViewedCollectionID = defaults.string(forKey: Keys.lastViewedCollectionID) ?? ""
        searchQueries = defaults.stringArray(forKey: Keys.searchQueries) ?? []
        usageViews = defaults.integer(forKey: Keys.usageViews)
        totalExports = defaults.integer(forKey: Keys.totalExports)
        newlyUnlockedAchievement = nil
    }

    private static func loadSlides(defaults: UserDefaults, themes: [Theme]) -> [StorySlide] {
        if let data = defaults.data(forKey: Keys.storySlides),
           let decoded = try? JSONDecoder().decode([StorySlide].self, from: data) {
            return decoded
        }
        if let data = defaults.data(forKey: Keys.annotations) {
            let defaultTheme = themes.first?.id
            return StorySlideMigration.migrate(from: data, defaultThemeID: defaultTheme)
        }
        return []
    }

    private func saveCodable<T: Encodable>(_ value: T, key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadCodable<T: Decodable>(key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func saveDictionary(_ dict: [String: Date], key: String) {
        let stringKeyed = dict.mapValues { $0.timeIntervalSince1970 }
        defaults.set(stringKeyed, forKey: key)
    }

    private static func loadDictionary(key: String, defaults: UserDefaults) -> [String: Date] {
        guard let raw = defaults.dictionary(forKey: key) as? [String: TimeInterval] else { return [:] }
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }
}

private extension Array {
    mutating func reorder(from source: IndexSet, to destination: Int) {
        guard !source.isEmpty else { return }
        let movedItems = source.sorted().map { self[$0] }
        var target = destination
        for index in source.sorted(by: >) {
            self.remove(at: index)
            if index < target { target -= 1 }
        }
        for (offset, item) in movedItems.enumerated() {
            self.insert(item, at: Swift.min(target + offset, count))
        }
    }
}
