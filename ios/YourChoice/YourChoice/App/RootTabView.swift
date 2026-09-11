import SwiftUI

struct RootTabView: View {
    @Environment(AppModel.self) private var app
    @Environment(VenueStore.self) private var store
    @Environment(LocationService.self) private var location

    var body: some View {
        @Bindable var app = app
        TabView {
            HomeView()
                .tabItem { Label("Now", systemImage: "sparkles") }
            MapScreen()
                .tabItem { Label("Map", systemImage: "map.fill") }
            FavoritesView()
                .tabItem { Label("Saved", systemImage: "heart.fill") }
            ProfileView()
                .tabItem { Label("You", systemImage: "person.crop.circle.fill") }
        }
        .tint(YC.Palette.brand)
        .fullScreenCover(item: $app.activeJourney) { item in
            JourneyView(start: item)
                .environment(app)
                .environment(store)
                .environment(location)
        }
        .task {
            location.start()
            // The automatic signal feed. Every tick, some venues receive new
            // POS or on-device dwell signals and the ranking re-evaluates.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
                store.tick()
                app.checkAlerts(using: store)
            }
        }
    }
}
