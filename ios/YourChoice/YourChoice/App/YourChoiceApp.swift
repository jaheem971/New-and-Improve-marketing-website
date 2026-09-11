import SwiftUI

@main
struct YourChoiceApp: App {
    @State private var store = VenueStore()
    @State private var app = AppModel()
    @State private var location = LocationService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(app)
                .environment(location)
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        ZStack {
            if app.hasOnboarded {
                RootTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: app.hasOnboarded)
    }
}
