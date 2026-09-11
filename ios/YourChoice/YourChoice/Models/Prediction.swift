import Foundation

enum Confidence: Int, Comparable, Hashable {
    case low = 0, medium, high

    static func < (lhs: Confidence, rhs: Confidence) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .low: return "Low confidence"
        case .medium: return "Medium confidence"
        case .high: return "High confidence"
        }
    }

    var shortLabel: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    var filledDots: Int { rawValue + 1 }
}

enum CrowdLevel: String, Hashable {
    case calm, lively, packed

    var label: String {
        switch self {
        case .calm: return "Calm"
        case .lively: return "Lively"
        case .packed: return "Packed"
        }
    }

    var symbol: String {
        switch self {
        case .calm: return "person.fill"
        case .lively: return "person.2.fill"
        case .packed: return "person.3.fill"
        }
    }
}

enum Trend: Hashable {
    case rising, steady, falling

    var symbol: String {
        switch self {
        case .rising: return "arrow.up.right"
        case .steady: return "arrow.right"
        case .falling: return "arrow.down.right"
        }
    }

    var label: String {
        switch self {
        case .rising: return "Getting busier"
        case .steady: return "Holding steady"
        case .falling: return "Calming down"
        }
    }
}

/// What the consumer sees: a model of the current situation, not the last
/// person's observation. Observed vs. predicted is always distinguishable.
struct Prediction: Hashable {
    var waitMinutes: Int
    var confidence: Confidence
    /// 0...1 raw confidence score behind the tier.
    var confidenceScore: Double
    /// Seconds since the newest live signal; nil when running on history alone.
    var freshness: TimeInterval?
    var crowd: CrowdLevel
    var seatingLikely: Bool
    var trend: Trend
    /// Contributing live sources, strongest first.
    var sources: [SignalSource]
    var liveSignalCount: Int
    /// What is usual at this venue right now (the historical baseline).
    var baselineMinutes: Int
    /// True when live evidence dominates the estimate.
    var isObserved: Bool

    var needsHumanHelp: Bool { confidence == .low }
    var deltaVsUsual: Int { waitMinutes - baselineMinutes }

    var waitLabel: String {
        waitMinutes <= 1 ? "No wait" : "~\(waitMinutes) min"
    }

    var kindLabel: String { isObserved ? "Observed" : "Predicted" }
}

/// Venue-specific typical conditions by hour, used as the baseline when
/// fresh signals are sparse.
struct HistoricalPattern: Hashable {
    /// 24 entries, typical wait in minutes at each hour.
    var hourly: [Double]
    var weekendMultiplier: Double

    struct Peak {
        var hour: Double
        var height: Double
        var width: Double
    }

    /// Builds a smooth daily curve from a base level plus gaussian peaks.
    static func curve(base: Double, peaks: [Peak], weekendMultiplier: Double = 1.15) -> HistoricalPattern {
        var hourly = [Double](repeating: 0, count: 24)
        for hour in 0..<24 {
            var value = base
            for peak in peaks {
                let distance = Double(hour) - peak.hour
                value += peak.height * exp(-(distance * distance) / (2 * peak.width * peak.width))
            }
            hourly[hour] = value
        }
        return HistoricalPattern(hourly: hourly, weekendMultiplier: weekendMultiplier)
    }

    func expectedWait(at date: Date, calendar: Calendar = .current) -> Double {
        let components = calendar.dateComponents([.hour, .minute, .weekday], from: date)
        let hour = Double(components.hour ?? 12) + Double(components.minute ?? 0) / 60
        let lower = Int(hour) % 24
        let upper = (lower + 1) % 24
        let fraction = hour - Double(lower)
        var value = hourly[lower] * (1 - fraction) + hourly[upper] * fraction
        if let weekday = components.weekday, weekday == 1 || weekday == 7 {
            value *= weekendMultiplier
        }
        return max(0, value)
    }

    func expectedWait(atHour hour: Int, on date: Date, calendar: Calendar = .current) -> Double {
        var value = hourly[max(0, min(23, hour))]
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 || weekday == 7 { value *= weekendMultiplier }
        return max(0, value)
    }
}
