import SwiftUI

enum HomeFilter: String, CaseIterable, Identifiable {
    case all, coffee, bakery, food, bubbleTea, workFriendly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All"
        case .coffee: return VenueCategory.coffee.label
        case .bakery: return VenueCategory.bakery.label
        case .food: return VenueCategory.food.label
        case .bubbleTea: return VenueCategory.bubbleTea.label
        case .workFriendly: return "Work-friendly"
        }
    }

    var symbol: String? {
        switch self {
        case .all: return nil
        case .coffee: return VenueCategory.coffee.symbol
        case .bakery: return VenueCategory.bakery.symbol
        case .food: return VenueCategory.food.symbol
        case .bubbleTea: return VenueCategory.bubbleTea.symbol
        case .workFriendly: return "laptopcomputer"
        }
    }

    func matches(_ venue: Venue) -> Bool {
        switch self {
        case .all: return true
        case .coffee: return venue.category == .coffee
        case .bakery: return venue.category == .bakery
        case .food: return venue.category == .food
        case .bubbleTea: return venue.category == .bubbleTea
        case .workFriendly: return venue.attributes.isSuperset(of: [.wifi, .laptopFriendly])
        }
    }
}

/// The decision screen. Opens straight to "where should I go right now?"
struct HomeView: View {
    @Environment(VenueStore.self) private var store
    @Environment(AppModel.self) private var app
    @Environment(LocationService.self) private var location

    @State private var filter: HomeFilter = .all
    @State private var path = NavigationPath()
    @State private var showAlerts = false

    private var ranked: [RankedVenue] {
        store.ranked(from: location.origin, preferences: app.preferences)
            .filter { filter.matches($0.venue) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: YC.Space.xl) {
                    header
                    filterRow
                    PrioritySelector()

                    let items = ranked
                    if let best = items.first, best.venue.isOpen() {
                        BestChoiceHero(item: best, onOpen: { path.append(best.id) }, onGo: { app.startJourney(to: best) })
                    }

                    if let help = store.humanHelpCandidate(from: location.origin, excluding: app.dismissedHelpVenueIDs) {
                        HumanHelpCard(
                            venue: help,
                            onAnswer: { option in
                                store.submitReport(venueID: help.id, minutes: option.minutes)
                                app.recordReport(isConfirmation: false)
                                withAnimation(.snappy) { app.dismissedHelpVenueIDs.insert(help.id) }
                            },
                            onDismiss: {
                                withAnimation(.snappy) { app.dismissedHelpVenueIDs.insert(help.id) }
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }

                    nearbySection(items)
                }
                .padding(.horizontal, YC.Space.lg)
                .padding(.bottom, YC.Space.xxl)
            }
            .background(YC.Palette.canvas)
            .refreshable { await store.refresh() }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { venueID in
                VenueDetailView(venueID: venueID)
            }
            .sheet(isPresented: $showAlerts) { AlertsView() }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(YC.Palette.brand)
                    Text(location.placeLabel)
                        .font(YCFont.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(app.greeting), \(app.user.name).")
                    .font(YCFont.subheadline)
                    .foregroundStyle(.secondary)
                Text("Where to right now?")
                    .font(YCFont.display(32))
            }
            Spacer()
            IconButton(symbol: "bell.fill", badge: app.unreadAlertCount) { showAlerts = true }
        }
        .padding(.top, YC.Space.sm)
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HomeFilter.allCases) { option in
                    FilterChip(title: option.label, symbol: option.symbol, isSelected: filter == option) {
                        withAnimation(.snappy) { filter = option }
                    }
                }
            }
            .padding(.horizontal, YC.Space.lg)
            .padding(.vertical, 4)
        }
        .padding(.horizontal, -YC.Space.lg)
    }

    private func nearbySection(_ items: [RankedVenue]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(
                title: "Nearby right now",
                subtitle: "\(items.count) places · ranked for \(app.preferences.priority.label.lowercased()) · \(YCFormat.relative(store.lastUpdated).lowercased())"
            )
            if items.isEmpty {
                ContentUnavailableView("Nothing matches yet", systemImage: "cup.and.saucer", description: Text("Try another filter or widen your walk radius."))
                    .ycCard()
            }
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    VenueCardView(item: item, isFavorite: app.isFavorite(item.id)) {
                        app.toggleFavorite(item.id)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: YC.Radius.card, style: .continuous))
                    .onTapGesture {
                        Haptics.tap()
                        path.append(item.id)
                    }
                }
            }
        }
    }
}

/// Fastest / Balanced / Comfort: the personalization dial.
struct PrioritySelector: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        HStack(spacing: 6) {
            ForEach(RankingPriority.allCases) { option in
                let selected = app.preferences.priority == option
                Button {
                    Haptics.selection()
                    withAnimation(.snappy) {
                        app.updatePreferences { $0.priority = option }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: option.symbol)
                            .font(.system(size: 12, weight: .bold))
                        Text(option.label)
                            .font(YCFont.subheadlineMedium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .background(selected ? YC.Palette.brand : Color.clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(YC.Palette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
