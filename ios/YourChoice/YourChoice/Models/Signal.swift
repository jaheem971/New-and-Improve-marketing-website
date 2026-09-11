import Foundation

/// The automatic signal framework from the product brief. Each source has a
/// baseline trust and a half-life: its influence decays as it ages.
enum SignalSource: String, CaseIterable, Codable, Hashable {
    case pos
    case camera
    case mobile
    case business
    case userReport

    var label: String {
        switch self {
        case .pos: return "Point of sale"
        case .camera: return "Occupancy sensor"
        case .mobile: return "On-device dwell"
        case .business: return "Venue update"
        case .userReport: return "Human report"
        }
    }

    var detail: String {
        switch self {
        case .pos: return "Orders entering vs. completed, prep speed, backlog"
        case .camera: return "Non-identifying queue length and occupancy"
        case .mobile: return "Aggregated arrival, dwell and departure patterns"
        case .business: return "Status supplied directly by the venue"
        case .userReport: return "One-tap observation from someone nearby"
        }
    }

    var symbol: String {
        switch self {
        case .pos: return "creditcard.fill"
        case .camera: return "camera.metering.matrix"
        case .mobile: return "iphone.radiowaves.left.and.right"
        case .business: return "storefront.fill"
        case .userReport: return "hand.raised.fill"
        }
    }

    /// Baseline trust used by the prediction engine before recency decay.
    var trust: Double {
        switch self {
        case .pos: return 1.0
        case .camera: return 0.9
        case .mobile: return 0.7
        case .business: return 0.6
        case .userReport: return 0.55
        }
    }

    /// Time for a signal's weight to halve.
    var halfLife: TimeInterval {
        switch self {
        case .pos: return 8 * 60
        case .camera: return 6 * 60
        case .mobile: return 12 * 60
        case .business: return 20 * 60
        case .userReport: return 10 * 60
        }
    }
}

/// One observation about a venue at a moment in time.
struct Signal: Identifiable, Hashable {
    let id: UUID
    var source: SignalSource
    /// Observed or inferred time-to-service in minutes.
    var waitMinutes: Double
    /// 0...1 estimated occupancy, when the source can see it.
    var occupancy: Double?
    var timestamp: Date
    var note: String?

    init(id: UUID = UUID(), source: SignalSource, waitMinutes: Double, occupancy: Double? = nil, timestamp: Date, note: String? = nil) {
        self.id = id
        self.source = source
        self.waitMinutes = waitMinutes
        self.occupancy = occupancy
        self.timestamp = timestamp
        self.note = note
    }
}

/// The one-tap answers a person can give when the system asks for help.
enum WaitReportOption: Int, CaseIterable, Identifiable {
    case none = 0
    case short = 5
    case medium = 10
    case long = 17

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .none: return "No wait"
        case .short: return "~5 min"
        case .medium: return "~10 min"
        case .long: return "15+ min"
        }
    }

    var subtitle: String {
        switch self {
        case .none: return "Walk right up"
        case .short: return "Short line"
        case .medium: return "Getting busy"
        case .long: return "Packed"
        }
    }

    var symbol: String {
        switch self {
        case .none: return "bolt.fill"
        case .short: return "figure.walk"
        case .medium: return "person.2.fill"
        case .long: return "person.3.fill"
        }
    }

    var minutes: Int { rawValue }
}
