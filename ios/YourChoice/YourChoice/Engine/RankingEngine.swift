import Foundation

/// A venue paired with its current prediction and the walk from the user.
struct RankedVenue: Identifiable, Hashable {
    let venue: Venue
    let prediction: Prediction
    let walkMinutes: Int
    let score: Double
    let reasons: [String]

    var id: String { venue.id }
    var totalMinutes: Int { walkMinutes + prediction.waitMinutes }
}

/// Answers the cross-venue question: "Given what is happening now, where
/// should I go?" A venue eight minutes away can beat one four minutes away
/// if its expected wait is much shorter.
struct RankingEngine {
    var predictionEngine = PredictionEngine()

    func rank(_ venues: [Venue], from origin: Coordinate, preferences: DecisionPreferences) -> [RankedVenue] {
        let now = predictionEngine.now
        let scored = venues.map { venue -> RankedVenue in
            let prediction = predictionEngine.predict(venue)
            let walk = origin.walkingMinutes(to: venue.coordinate)
            let score = score(venue: venue, prediction: prediction, walk: walk, preferences: preferences, now: now)
            return RankedVenue(venue: venue, prediction: prediction, walkMinutes: walk, score: score, reasons: [])
        }
        .sorted { $0.score < $1.score }

        return scored.enumerated().map { index, item in
            RankedVenue(
                venue: item.venue,
                prediction: item.prediction,
                walkMinutes: item.walkMinutes,
                score: item.score,
                reasons: reasons(for: item, isTop: index == 0, preferences: preferences, now: now)
            )
        }
    }

    private func score(venue: Venue, prediction: Prediction, walk: Int, preferences: DecisionPreferences, now: Date) -> Double {
        let weights: (wait: Double, walk: Double, comfort: Double)
        switch preferences.priority {
        case .fastest:
            weights = (wait: 1.0, walk: 1.0, comfort: 0.5)
        case .balanced:
            weights = (wait: 1.0, walk: 0.85, comfort: 2.0)
        case .comfort:
            weights = (wait: 0.7, walk: 0.6, comfort: 4.0)
        }
        let comfortBonus = weights.comfort

        var score = Double(prediction.waitMinutes) * weights.wait + Double(walk) * weights.walk

        // Uncertainty costs something: a confident 6 beats a guessed 5.
        score += (1 - prediction.confidenceScore) * 4

        if walk > preferences.maxWalkMinutes {
            score += Double(walk - preferences.maxWalkMinutes) * 1.5
        }

        let matched = preferences.mustHaves.intersection(venue.attributes).count
        let missing = preferences.mustHaves.count - matched
        score -= Double(matched) * comfortBonus
        score += Double(missing) * 6

        if preferences.priority == .comfort {
            if venue.attributes.contains(.quiet) { score -= 2 }
            if prediction.seatingLikely { score -= 2 }
            if prediction.crowd == .packed { score += 3 }
        }

        if !venue.isOpen(at: now) { score += 1_000 }
        return score
    }

    private func reasons(for item: RankedVenue, isTop: Bool, preferences: DecisionPreferences, now: Date) -> [String] {
        var reasons: [String] = []
        if !item.venue.isOpen(at: now) { return ["Closed right now"] }
        if isTop { reasons.append(preferences.priority == .comfort ? "Best fit for you" : "Fastest overall") }
        if item.prediction.waitMinutes <= 2 { reasons.append("Almost no wait") }
        if item.prediction.deltaVsUsual <= -4 { reasons.append("Quieter than usual") }
        if item.prediction.confidence == .high { reasons.append("High-confidence signal") }
        let matched = preferences.mustHaves.intersection(item.venue.attributes)
        if !preferences.mustHaves.isEmpty, matched.count == preferences.mustHaves.count {
            reasons.append("Has your must-haves")
        }
        if preferences.priority == .comfort, item.prediction.seatingLikely { reasons.append("Seats likely") }
        if item.prediction.trend == .rising { reasons.append("Filling up") }
        return Array(reasons.prefix(2))
    }
}
