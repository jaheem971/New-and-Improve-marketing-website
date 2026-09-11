import Foundation

/// Moves the question from "What is fastest?" to "What is best for me right now?"
enum RankingPriority: String, CaseIterable, Codable, Identifiable, Hashable {
    case fastest, balanced, comfort

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fastest: return "Fastest"
        case .balanced: return "Balanced"
        case .comfort: return "Comfort"
        }
    }

    var symbol: String {
        switch self {
        case .fastest: return "bolt.fill"
        case .balanced: return "scale.3D"
        case .comfort: return "sofa.fill"
        }
    }

    var blurb: String {
        switch self {
        case .fastest: return "Shortest wait plus walk. Nothing else matters."
        case .balanced: return "Fast, but a few extra minutes are fine for a better spot."
        case .comfort: return "Quiet, seats, power and Wi-Fi come first."
        }
    }
}

struct DecisionPreferences: Codable, Hashable {
    var priority: RankingPriority = .balanced
    var maxWalkMinutes: Int = 10
    var mustHaves: Set<VenueAttribute> = []
    var betterOptionAlerts: Bool = true
    var favoriteQuietAlerts: Bool = true
}

struct UserProfile: Codable, Hashable {
    var name: String = "Jaheem"
    var points: Int = 240
    var reportCount: Int = 18
    var accurateReportCount: Int = 16
    var isPro: Bool = false

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }.map(String.init)
        return letters.joined().uppercased()
    }

    /// Reputation rewards accuracy, not volume.
    var reputation: Int {
        guard reportCount > 0 else { return 50 }
        let accuracy = Double(accurateReportCount) / Double(reportCount)
        let volumeBonus = min(10, reportCount / 5)
        return min(100, Int(accuracy * 90) + volumeBonus)
    }

    var accuracyPercent: Int {
        guard reportCount > 0 else { return 0 }
        return Int((Double(accurateReportCount) / Double(reportCount) * 100).rounded())
    }

    var tier: String {
        switch reputation {
        case 90...: return "Trusted scout"
        case 70..<90: return "Reliable scout"
        case 50..<70: return "Scout"
        default: return "Newcomer"
        }
    }
}

struct LeaderboardEntry: Identifiable, Hashable {
    let id: String
    var name: String
    var points: Int
    var accuracy: Int
    var isYou: Bool
}

struct AppAlert: Identifiable, Hashable {
    enum Kind: Hashable {
        case quietNow, betterOption, bestTime, system

        var symbol: String {
            switch self {
            case .quietNow: return "sparkles"
            case .betterOption: return "arrow.triangle.swap"
            case .bestTime: return "clock.badge.checkmark"
            case .system: return "bell.fill"
            }
        }
    }

    let id: UUID
    var kind: Kind
    var title: String
    var message: String
    var date: Date
    var venueID: String?
    var isRead: Bool

    init(id: UUID = UUID(), kind: Kind, title: String, message: String, date: Date = .now, venueID: String? = nil, isRead: Bool = false) {
        self.id = id
        self.kind = kind
        self.title = title
        self.message = message
        self.date = date
        self.venueID = venueID
        self.isRead = isRead
    }
}
