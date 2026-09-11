import Foundation

/// A latitude/longitude pair kept free of MapKit so the models and engines
/// stay pure Foundation (and testable anywhere).
struct Coordinate: Hashable, Codable {
    var latitude: Double
    var longitude: Double

    /// Great-circle distance in metres (haversine).
    func distance(to other: Coordinate) -> Double {
        let earthRadius = 6_371_000.0
        let dLat = (other.latitude - latitude) * .pi / 180
        let dLon = (other.longitude - longitude) * .pi / 180
        let lat1 = latitude * .pi / 180
        let lat2 = other.latitude * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * earthRadius * atan2(sqrt(a), sqrt(1 - a))
    }

    /// Walking time at a relaxed city pace (~80 m/min), never less than a minute.
    func walkingMinutes(to other: Coordinate) -> Int {
        max(1, Int((distance(to: other) / 80).rounded()))
    }
}

/// Coffee is the wedge; the same intelligence layer expands to other place types.
enum VenueCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    case coffee, bakery, food, bubbleTea

    var id: String { rawValue }

    var label: String {
        switch self {
        case .coffee: return "Coffee"
        case .bakery: return "Bakery"
        case .food: return "Food"
        case .bubbleTea: return "Bubble tea"
        }
    }

    var symbol: String {
        switch self {
        case .coffee: return "cup.and.saucer.fill"
        case .bakery: return "birthday.cake.fill"
        case .food: return "fork.knife"
        case .bubbleTea: return "takeoutbag.and.cup.and.straw.fill"
        }
    }
}

/// "Knowing more than the queue": the attributes a person may value more than speed.
enum VenueAttribute: String, CaseIterable, Codable, Identifiable, Hashable {
    case wifi, power, laptopFriendly, quiet, outdoorSeating, petFriendly, takeaway, oatMilk

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .power: return "Power outlets"
        case .laptopFriendly: return "Laptop-friendly"
        case .quiet: return "Quiet"
        case .outdoorSeating: return "Outdoor seating"
        case .petFriendly: return "Dog-friendly"
        case .takeaway: return "Takeaway"
        case .oatMilk: return "Oat milk"
        }
    }

    var shortLabel: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .power: return "Power"
        case .laptopFriendly: return "Laptop"
        case .quiet: return "Quiet"
        case .outdoorSeating: return "Outdoor"
        case .petFriendly: return "Dogs ok"
        case .takeaway: return "Takeaway"
        case .oatMilk: return "Oat milk"
        }
    }

    var symbol: String {
        switch self {
        case .wifi: return "wifi"
        case .power: return "powerplug.fill"
        case .laptopFriendly: return "laptopcomputer"
        case .quiet: return "speaker.slash.fill"
        case .outdoorSeating: return "sun.max.fill"
        case .petFriendly: return "pawprint.fill"
        case .takeaway: return "bag.fill"
        case .oatMilk: return "leaf.fill"
        }
    }

    /// Attributes a remote worker is likely to filter on.
    static let workFriendly: Set<VenueAttribute> = [.wifi, .power, .laptopFriendly]
}

struct Venue: Identifiable, Hashable {
    let id: String
    var name: String
    var category: VenueCategory
    var tagline: String
    var address: String
    var coordinate: Coordinate
    var rating: Double
    /// 1 = €, 2 = €€, 3 = €€€
    var priceLevel: Int
    var attributes: Set<VenueAttribute>
    var opensAt: Int
    var closesAt: Int
    /// Index into the artwork palette (the MVP has no photography pipeline yet).
    var artworkIndex: Int
    var history: HistoricalPattern
    var signals: [Signal]
    /// True when the venue's POS/business systems feed YourChoice directly.
    var isPartner: Bool
    /// 0...1 – how likely this venue is to receive an automatic signal per tick.
    /// Low coverage is exactly the situation where the app asks a human.
    var automaticCoverage: Double

    var priceLabel: String { String(repeating: "€", count: max(1, min(3, priceLevel))) }

    func isOpen(at date: Date = .now, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: date)
        return hour >= opensAt && hour < closesAt
    }

    var hoursLabel: String { "\(opensAt):00 – \(closesAt):00" }
}
