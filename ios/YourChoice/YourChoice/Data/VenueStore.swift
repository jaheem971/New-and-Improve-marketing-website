import Foundation
import Observation

/// Holds the venue set and simulates the automatic signal feed. In production
/// this is where POS webhooks, aggregated dwell events and business updates
/// land; here it drifts signals so the app feels alive.
@Observable
final class VenueStore {
    private(set) var venues: [Venue]
    private(set) var lastUpdated: Date = .now
    private(set) var isRefreshing = false

    init(venues: [Venue] = MockVenues.cannes()) {
        self.venues = venues
    }

    // MARK: - Reads

    func venue(id: String) -> Venue? {
        venues.first { $0.id == id }
    }

    func prediction(for venue: Venue, now: Date = .now) -> Prediction {
        PredictionEngine(now: now).predict(venue)
    }

    func ranked(from origin: Coordinate, preferences: DecisionPreferences, now: Date = .now) -> [RankedVenue] {
        RankingEngine(predictionEngine: PredictionEngine(now: now))
            .rank(venues, from: origin, preferences: preferences)
    }

    func rankedItem(id: String, from origin: Coordinate, preferences: DecisionPreferences) -> RankedVenue? {
        ranked(from: origin, preferences: preferences).first { $0.id == id }
    }

    /// The nearby venue where the system most needs a human: low confidence,
    /// open, and close enough that a one-tap answer is realistic.
    func humanHelpCandidate(from origin: Coordinate, maxWalk: Int = 7, excluding: Set<String> = []) -> Venue? {
        let now = Date.now
        let engine = PredictionEngine(now: now)
        return venues
            .filter { !excluding.contains($0.id) && $0.isOpen(at: now) }
            .filter { engine.predict($0).needsHumanHelp }
            .filter { origin.walkingMinutes(to: $0.coordinate) <= maxWalk }
            .min { origin.distance(to: $0.coordinate) < origin.distance(to: $1.coordinate) }
    }

    // MARK: - Writes

    /// A one-tap human report. Serves as a correction, a validation point and
    /// a training signal.
    func submitReport(venueID: String, minutes: Int, isConfirmation: Bool = false) {
        guard let index = venues.firstIndex(where: { $0.id == venueID }) else { return }
        let note = isConfirmation ? "Confirmed on arrival" : "Reported \(minutes <= 1 ? "no wait" : "~\(minutes) min")"
        venues[index].signals.append(
            Signal(source: .userReport, waitMinutes: Double(minutes), occupancy: nil, timestamp: .now, note: note)
        )
        lastUpdated = .now
    }

    /// Simulates automatic signals arriving. Partner venues emit POS data;
    /// others emit aggregated on-device dwell signals. Venues without
    /// automatic coverage stay quiet, which is exactly when the app asks a human.
    func tick(now: Date = .now) {
        let engine = PredictionEngine(now: now)
        for index in venues.indices {
            guard Double.random(in: 0...1) < venues[index].automaticCoverage * 0.35 else { continue }
            let venue = venues[index]
            let current = engine.predict(venue)
            let drift = Double.random(in: -2.5...2.5)
            let wait = max(0, Double(current.waitMinutes) + drift)
            let occupancy = min(1, max(0.05, wait / 20 + Double.random(in: -0.1...0.1)))
            let source: SignalSource = venue.isPartner ? (Bool.random() ? .pos : .mobile) : .mobile
            venues[index].signals.append(
                Signal(source: source, waitMinutes: wait, occupancy: occupancy, timestamp: now)
            )
            venues[index].signals.removeAll { now.timeIntervalSince($0.timestamp) > 90 * 60 }
        }
        lastUpdated = now
    }

    @MainActor
    func refresh() async {
        isRefreshing = true
        try? await Task.sleep(for: .milliseconds(700))
        tick()
        tick()
        isRefreshing = false
    }
}
