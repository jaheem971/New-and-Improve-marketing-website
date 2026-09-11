import Foundation
import Observation

/// User-level state: profile, preferences, favorites, alerts and the active
/// journey. Persisted to UserDefaults for the MVP.
@Observable
final class AppModel {
    var user: UserProfile
    var preferences: DecisionPreferences
    var favorites: Set<String>
    var hasOnboarded: Bool
    var alerts: [AppAlert]
    var activeJourney: RankedVenue?
    var dismissedHelpVenueIDs: Set<String> = []

    /// Last wait seen per favorite, used to notice when a place gets quiet.
    private var lastKnownWaits: [String: Int] = [:]

    private let defaults: UserDefaults
    private enum Key {
        static let user = "yc.user"
        static let preferences = "yc.preferences"
        static let favorites = "yc.favorites"
        static let onboarded = "yc.onboarded"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let decoder = JSONDecoder()
        user = defaults.data(forKey: Key.user).flatMap { try? decoder.decode(UserProfile.self, from: $0) } ?? UserProfile()
        preferences = defaults.data(forKey: Key.preferences).flatMap { try? decoder.decode(DecisionPreferences.self, from: $0) } ?? DecisionPreferences()
        favorites = Set(defaults.stringArray(forKey: Key.favorites) ?? ["bloom-concept", "studio-grind"])
        hasOnboarded = defaults.bool(forKey: Key.onboarded)
        alerts = [
            AppAlert(
                kind: .bestTime,
                title: "Best time for Bloom Concept",
                message: "Usually calmest around 14:00 today. We'll nudge you if that changes.",
                date: Date.now.addingTimeInterval(-38 * 60),
                venueID: "bloom-concept"
            ),
            AppAlert(
                kind: .system,
                title: "Welcome to Cannes",
                message: "12 places nearby are live. Know before you go.",
                date: Date.now.addingTimeInterval(-3 * 3600),
                isRead: true
            ),
        ]
    }

    // MARK: - Derived

    var unreadAlertCount: Int { alerts.filter { !$0.isRead }.count }

    var leaderboard: [LeaderboardEntry] {
        let you = LeaderboardEntry(id: "you", name: "\(user.name) (you)", points: user.points, accuracy: user.accuracyPercent, isYou: true)
        return (MockVenues.leaderboard + [you]).sorted { $0.points > $1.points }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Late night"
        }
    }

    func isFavorite(_ venueID: String) -> Bool { favorites.contains(venueID) }

    // MARK: - Actions

    func completeOnboarding() {
        hasOnboarded = true
        defaults.set(true, forKey: Key.onboarded)
    }

    func toggleFavorite(_ venueID: String) {
        if favorites.contains(venueID) {
            favorites.remove(venueID)
        } else {
            favorites.insert(venueID)
        }
        defaults.set(Array(favorites), forKey: Key.favorites)
    }

    /// Reports earn points; confirmations on arrival earn more because they
    /// validate the model.
    func recordReport(isConfirmation: Bool) {
        user.reportCount += 1
        user.accurateReportCount += 1
        user.points += isConfirmation ? 15 : 10
        persistUser()
    }

    func setPro(_ isPro: Bool) {
        user.isPro = isPro
        persistUser()
    }

    func updatePreferences(_ transform: (inout DecisionPreferences) -> Void) {
        transform(&preferences)
        persistPreferences()
    }

    func persistPreferences() {
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: Key.preferences)
        }
    }

    func markAlertsRead() {
        for index in alerts.indices { alerts[index].isRead = true }
    }

    func startJourney(to item: RankedVenue) {
        activeJourney = item
    }

    func endJourney() {
        activeJourney = nil
    }

    /// Runs on each feed tick: notices favorites that just got quiet.
    func checkAlerts(using store: VenueStore) {
        guard preferences.favoriteQuietAlerts else { return }
        for venueID in favorites {
            guard let venue = store.venue(id: venueID) else { continue }
            let wait = store.prediction(for: venue).waitMinutes
            if let previous = lastKnownWaits[venueID], previous >= 9, wait <= 4 {
                alerts.insert(
                    AppAlert(
                        kind: .quietNow,
                        title: "\(venue.name) just got quiet",
                        message: "Wait dropped from ~\(previous) to ~\(wait) min. Good moment to go.",
                        venueID: venueID
                    ),
                    at: 0
                )
            }
            lastKnownWaits[venueID] = wait
        }
    }

    private func persistUser() {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: Key.user)
        }
    }
}
