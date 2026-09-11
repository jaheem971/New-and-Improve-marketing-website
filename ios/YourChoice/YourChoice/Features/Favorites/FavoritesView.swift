import SwiftUI

struct FavoritesView: View {
    @Environment(VenueStore.self) private var store
    @Environment(AppModel.self) private var app
    @Environment(LocationService.self) private var location

    @State private var path = NavigationPath()

    private var items: [RankedVenue] {
        store.ranked(from: location.origin, preferences: app.preferences)
            .filter { app.favorites.contains($0.id) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            let saved = items
            Group {
                if saved.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing saved yet", systemImage: "heart")
                    } description: {
                        Text("Tap the heart on any place. We'll tell you when your favourites get quiet.")
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live waits at the places you love, ranked for right now.")
                                .font(YCFont.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 4)
                            ForEach(saved) { item in
                                VenueCardView(item: item, isFavorite: true) {
                                    withAnimation(.snappy) { app.toggleFavorite(item.id) }
                                }
                                .contentShape(RoundedRectangle(cornerRadius: YC.Radius.card, style: .continuous))
                                .onTapGesture {
                                    Haptics.tap()
                                    path.append(item.id)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(YC.Palette.canvas)
            .navigationTitle("Saved")
            .navigationDestination(for: String.self) { venueID in
                VenueDetailView(venueID: venueID)
            }
        }
    }
}
