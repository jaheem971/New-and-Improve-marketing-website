import Foundation

/// The Cannes pilot dataset. A dense, walkable market where people make
/// spontaneous venue decisions. Names are fictional.
enum MockVenues {
    /// A hotel on La Croisette: the demo starting point from the brief's story.
    static let demoOrigin = Coordinate(latitude: 43.5510, longitude: 7.0225)

    static func cannes(now: Date = .now) -> [Venue] {
        func ago(_ minutes: Double) -> Date { now.addingTimeInterval(-minutes * 60) }
        func signal(_ source: SignalSource, _ wait: Double, _ minutesAgo: Double, occupancy: Double? = nil, note: String? = nil) -> Signal {
            Signal(source: source, waitMinutes: wait, occupancy: occupancy, timestamp: ago(minutesAgo), note: note)
        }

        let cafeCurve = HistoricalPattern.curve(base: 2, peaks: [
            .init(hour: 8.5, height: 6, width: 1.1),
            .init(hour: 10.5, height: 9, width: 1.5),
            .init(hour: 13, height: 5, width: 1.0),
            .init(hour: 16, height: 4, width: 1.3),
        ])
        let touristCurve = HistoricalPattern.curve(base: 4, peaks: [
            .init(hour: 9, height: 8, width: 1.2),
            .init(hour: 11, height: 14, width: 1.8),
            .init(hour: 15, height: 9, width: 1.6),
        ], weekendMultiplier: 1.3)
        let bakeryCurve = HistoricalPattern.curve(base: 1.5, peaks: [
            .init(hour: 7.5, height: 7, width: 1.0),
            .init(hour: 12.5, height: 10, width: 1.2),
            .init(hour: 18, height: 6, width: 1.0),
        ])
        let lunchCurve = HistoricalPattern.curve(base: 3, peaks: [
            .init(hour: 12.5, height: 14, width: 1.2),
            .init(hour: 19.5, height: 10, width: 1.4),
        ])
        let quietCurve = HistoricalPattern.curve(base: 1.5, peaks: [
            .init(hour: 10, height: 5, width: 1.6),
            .init(hour: 15, height: 4, width: 1.6),
        ], weekendMultiplier: 1.05)

        return [
            Venue(
                id: "bloom-concept",
                name: "Bloom Concept",
                category: .coffee,
                tagline: "Specialty roasts, bright room, fast bar",
                address: "12 Rue d'Antibes",
                coordinate: Coordinate(latitude: 43.5522, longitude: 7.0201),
                rating: 4.7, priceLevel: 2,
                attributes: [.wifi, .oatMilk, .takeaway, .outdoorSeating],
                opensAt: 7, closesAt: 19, artworkIndex: 0,
                history: cafeCurve,
                signals: [
                    signal(.pos, 3.2, 1, occupancy: 0.42, note: "Orders completing faster than they arrive"),
                    signal(.mobile, 3.6, 4, occupancy: 0.4),
                    signal(.userReport, 3, 9, note: "Reported ~5 min"),
                    signal(.pos, 4.1, 12, occupancy: 0.5),
                ],
                isPartner: true, automaticCoverage: 0.9
            ),
            Venue(
                id: "cafe-croisette",
                name: "Café Croisette",
                category: .coffee,
                tagline: "Seafront terrace, iconic and always busy",
                address: "58 Boulevard de la Croisette",
                coordinate: Coordinate(latitude: 43.5506, longitude: 7.0250),
                rating: 4.3, priceLevel: 3,
                attributes: [.outdoorSeating, .petFriendly],
                opensAt: 8, closesAt: 23, artworkIndex: 1,
                history: touristCurve,
                signals: [
                    signal(.camera, 16, 2, occupancy: 0.92, note: "9 in queue, 0.6 served/min"),
                    signal(.mobile, 18, 5, occupancy: 0.9),
                    signal(.userReport, 17, 3, note: "Reported 15+ min"),
                    signal(.mobile, 13, 15, occupancy: 0.8),
                ],
                isPartner: false, automaticCoverage: 0.7
            ),
            Venue(
                id: "la-petite-tasse",
                name: "La Petite Tasse",
                category: .coffee,
                tagline: "Quiet back room made for laptops",
                address: "3 Rue Hoche",
                coordinate: Coordinate(latitude: 43.5540, longitude: 7.0165),
                rating: 4.6, priceLevel: 2,
                attributes: [.wifi, .power, .laptopFriendly, .quiet, .oatMilk],
                opensAt: 8, closesAt: 18, artworkIndex: 2,
                history: quietCurve,
                signals: [
                    signal(.mobile, 6.5, 7, occupancy: 0.55),
                    signal(.mobile, 7.5, 18, occupancy: 0.6),
                ],
                isPartner: false, automaticCoverage: 0.5
            ),
            Venue(
                id: "marche-roastery",
                name: "Marché Roastery",
                category: .coffee,
                tagline: "Market-side espresso, standing bar",
                address: "Place du Marché Forville",
                coordinate: Coordinate(latitude: 43.5532, longitude: 7.0128),
                rating: 4.5, priceLevel: 1,
                attributes: [.takeaway, .outdoorSeating, .petFriendly],
                opensAt: 6, closesAt: 15, artworkIndex: 3,
                history: cafeCurve,
                signals: [
                    signal(.business, 5, 14, occupancy: 0.5, note: "Venue marked 'normal service'"),
                    signal(.mobile, 4.5, 6, occupancy: 0.48),
                ],
                isPartner: false, automaticCoverage: 0.6
            ),
            Venue(
                id: "suquet-coffee-house",
                name: "Suquet Coffee House",
                category: .coffee,
                tagline: "Hillside hideout above the old port",
                address: "21 Rue Saint-Antoine",
                coordinate: Coordinate(latitude: 43.5518, longitude: 7.0112),
                rating: 4.4, priceLevel: 2,
                attributes: [.quiet, .outdoorSeating, .oatMilk],
                opensAt: 8, closesAt: 18, artworkIndex: 4,
                history: quietCurve,
                signals: [
                    signal(.userReport, 4, 41, note: "Reported ~5 min"),
                ],
                isPartner: false, automaticCoverage: 0.0
            ),
            Venue(
                id: "atelier-brule",
                name: "Atelier Brûlé",
                category: .bakery,
                tagline: "Wood-fired viennoiserie, lines move fast",
                address: "8 Rue Meynadier",
                coordinate: Coordinate(latitude: 43.5535, longitude: 7.0195),
                rating: 4.8, priceLevel: 2,
                attributes: [.takeaway],
                opensAt: 7, closesAt: 19, artworkIndex: 5,
                history: bakeryCurve,
                signals: [
                    signal(.mobile, 10, 3, occupancy: 0.7),
                    signal(.mobile, 7, 10, occupancy: 0.6),
                    signal(.userReport, 5, 16, note: "Reported ~5 min"),
                ],
                isPartner: false, automaticCoverage: 0.6
            ),
            Venue(
                id: "palais-espresso",
                name: "Palais Espresso Bar",
                category: .coffee,
                tagline: "Two-storey bar opposite the Palais",
                address: "1 Boulevard de la Croisette",
                coordinate: Coordinate(latitude: 43.5500, longitude: 7.0175),
                rating: 4.2, priceLevel: 2,
                attributes: [.wifi, .takeaway, .outdoorSeating, .oatMilk],
                opensAt: 7, closesAt: 21, artworkIndex: 6,
                history: touristCurve,
                signals: [
                    signal(.pos, 11, 2, occupancy: 0.72, note: "Backlog clearing"),
                    signal(.pos, 15, 9, occupancy: 0.85),
                    signal(.mobile, 14, 12, occupancy: 0.8),
                ],
                isPartner: true, automaticCoverage: 0.9
            ),
            Venue(
                id: "vieux-port-cafe",
                name: "Le Vieux Port Café",
                category: .coffee,
                tagline: "Harbour view, slow mornings",
                address: "Quai Saint-Pierre",
                coordinate: Coordinate(latitude: 43.5512, longitude: 7.0140),
                rating: 4.1, priceLevel: 2,
                attributes: [.outdoorSeating, .petFriendly, .wifi],
                opensAt: 7, closesAt: 22, artworkIndex: 7,
                history: cafeCurve,
                signals: [
                    signal(.mobile, 6, 5, occupancy: 0.5),
                    signal(.business, 5, 22, occupancy: 0.45),
                ],
                isPartner: false, automaticCoverage: 0.6
            ),
            Venue(
                id: "nova-bubble-tea",
                name: "Nova Bubble Tea",
                category: .bubbleTea,
                tagline: "Taro, brown sugar, and a fast counter",
                address: "30 Rue d'Antibes",
                coordinate: Coordinate(latitude: 43.5528, longitude: 7.0215),
                rating: 4.5, priceLevel: 1,
                attributes: [.takeaway, .wifi],
                opensAt: 11, closesAt: 22, artworkIndex: 8,
                history: cafeCurve,
                signals: [
                    signal(.mobile, 4, 6, occupancy: 0.4),
                    signal(.userReport, 5, 11, note: "Reported ~5 min"),
                ],
                isPartner: false, automaticCoverage: 0.5
            ),
            Venue(
                id: "boulangerie-meynadier",
                name: "Boulangerie Meynadier",
                category: .bakery,
                tagline: "Neighbourhood bakery, baguettes till noon",
                address: "44 Rue Meynadier",
                coordinate: Coordinate(latitude: 43.5525, longitude: 7.0150),
                rating: 4.6, priceLevel: 1,
                attributes: [.takeaway, .petFriendly],
                opensAt: 6, closesAt: 19, artworkIndex: 9,
                history: bakeryCurve,
                signals: [
                    signal(.mobile, 11, 8, occupancy: 0.7),
                    signal(.mobile, 9, 19, occupancy: 0.6),
                ],
                isPartner: false, automaticCoverage: 0.5
            ),
            Venue(
                id: "forville-kitchen",
                name: "Forville Kitchen",
                category: .food,
                tagline: "Market lunch plates, counter service",
                address: "6 Rue Louis Blanc",
                coordinate: Coordinate(latitude: 43.5536, longitude: 7.0135),
                rating: 4.4, priceLevel: 2,
                attributes: [.outdoorSeating, .takeaway, .wifi],
                opensAt: 11, closesAt: 22, artworkIndex: 10,
                history: lunchCurve,
                signals: [
                    signal(.pos, 13, 3, occupancy: 0.8, note: "Kitchen backlog 6 tickets"),
                    signal(.mobile, 14, 7, occupancy: 0.8),
                ],
                isPartner: true, automaticCoverage: 0.8
            ),
            Venue(
                id: "studio-grind",
                name: "Studio Grind",
                category: .coffee,
                tagline: "Coworking café with booths and outlets",
                address: "17 Rue des Serbes",
                coordinate: Coordinate(latitude: 43.5545, longitude: 7.0240),
                rating: 4.7, priceLevel: 2,
                attributes: [.wifi, .power, .laptopFriendly, .quiet, .oatMilk, .takeaway],
                opensAt: 7, closesAt: 20, artworkIndex: 11,
                history: quietCurve,
                signals: [
                    signal(.pos, 2, 1, occupancy: 0.35, note: "No backlog"),
                    signal(.pos, 2.5, 6, occupancy: 0.38),
                    signal(.mobile, 3, 4, occupancy: 0.4),
                    signal(.userReport, 0, 8, note: "Reported no wait"),
                ],
                isPartner: true, automaticCoverage: 0.9
            ),
        ]
    }

    static let leaderboard: [LeaderboardEntry] = [
        LeaderboardEntry(id: "1", name: "Camille R.", points: 1_240, accuracy: 96, isYou: false),
        LeaderboardEntry(id: "2", name: "Théo M.", points: 980, accuracy: 91, isYou: false),
        LeaderboardEntry(id: "3", name: "Inès D.", points: 640, accuracy: 94, isYou: false),
        LeaderboardEntry(id: "4", name: "Marco V.", points: 410, accuracy: 82, isYou: false),
        LeaderboardEntry(id: "5", name: "Léa B.", points: 190, accuracy: 88, isYou: false),
    ]
}
