import Foundation

/// The central intelligence layer. Signals feed the engine; the engine
/// produces an estimate and a confidence level. It considers how recent each
/// signal is, how many agree, what normally happens at this venue at this
/// time, whether conditions are changing, and how trustworthy each source is.
struct PredictionEngine {
    var now: Date = .now
    /// Weight of the historical baseline relative to live signals.
    var baselineWeight: Double = 0.35
    /// Signals older than this are ignored outright.
    var maxSignalAge: TimeInterval = 45 * 60

    private struct WeightedSignal {
        let signal: Signal
        let weight: Double
    }

    func predict(_ venue: Venue) -> Prediction {
        let baseline = venue.history.expectedWait(at: now)

        // 1. Recency-decayed, trust-weighted live signals.
        var weighted: [WeightedSignal] = []
        for signal in venue.signals {
            let age = now.timeIntervalSince(signal.timestamp)
            guard age >= 0, age <= maxSignalAge else { continue }
            let decay = exp(-age / signal.source.halfLife * log(2))
            weighted.append(WeightedSignal(signal: signal, weight: signal.source.trust * decay))
        }

        let liveWeight = weighted.reduce(0) { $0 + $1.weight }
        let liveMean: Double = liveWeight > 0
            ? weighted.reduce(0) { $0 + $1.weight * $1.signal.waitMinutes } / liveWeight
            : baseline

        // 2. Blend live evidence with the historical baseline.
        let blended = (liveMean * liveWeight + baseline * baselineWeight) / (liveWeight + baselineWeight)

        // 3. Confidence: how much live evidence there is, and how much it agrees.
        let variance: Double = liveWeight > 0
            ? weighted.reduce(0) { $0 + $1.weight * pow($1.signal.waitMinutes - liveMean, 2) } / liveWeight
            : 0
        let spread = sqrt(variance)
        let agreement = 1 - min(1, spread / max(4, liveMean))
        let strength = min(1, liveWeight / 1.4)
        let score = liveWeight > 0 ? strength * 0.65 + agreement * 0.35 : 0.15
        let confidence: Confidence = score >= 0.62 ? .high : (score >= 0.35 ? .medium : .low)

        // 4. Freshness of the newest contributing signal.
        let newest = weighted.map { $0.signal.timestamp }.max()
        let freshness = newest.map { now.timeIntervalSince($0) }

        // 5. Crowding from occupancy where available, otherwise inferred from wait.
        var occupancyWeight = 0.0
        var occupancySum = 0.0
        for item in weighted {
            guard let occupancy = item.signal.occupancy else { continue }
            occupancyWeight += item.weight
            occupancySum += occupancy * item.weight
        }
        let occupancy = occupancyWeight > 0 ? occupancySum / occupancyWeight : min(1, blended / 20)
        let crowd: CrowdLevel = occupancy < 0.45 ? .calm : (occupancy < 0.75 ? .lively : .packed)

        // 6. Trend: recent window vs. the window before it.
        let recent = weighted.filter { now.timeIntervalSince($0.signal.timestamp) <= 6 * 60 }
        let earlier = weighted.filter {
            let age = now.timeIntervalSince($0.signal.timestamp)
            return age > 6 * 60 && age <= 20 * 60
        }
        var trend: Trend = .steady
        if let recentMean = mean(recent), let earlierMean = mean(earlier) {
            if recentMean - earlierMean >= 2.5 {
                trend = .rising
            } else if earlierMean - recentMean >= 2.5 {
                trend = .falling
            }
        }

        // 7. Which sources carried the estimate, strongest first.
        var sourceWeights: [SignalSource: Double] = [:]
        for item in weighted {
            sourceWeights[item.signal.source, default: 0] += item.weight
        }
        let sources = sourceWeights.sorted { $0.value > $1.value }.map { $0.key }

        return Prediction(
            waitMinutes: Int(blended.rounded()),
            confidence: confidence,
            confidenceScore: score,
            freshness: freshness,
            crowd: crowd,
            seatingLikely: occupancy < 0.7,
            trend: trend,
            sources: sources,
            liveSignalCount: weighted.count,
            baselineMinutes: Int(baseline.rounded()),
            isObserved: liveWeight > baselineWeight
        )
    }

    private func mean(_ items: [WeightedSignal]) -> Double? {
        let total = items.reduce(0) { $0 + $1.weight }
        guard total > 0 else { return nil }
        return items.reduce(0) { $0 + $1.weight * $1.signal.waitMinutes } / total
    }
}
