import MapKit
import SwiftUI

extension Coordinate {
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// The live decision map: every pin is a current wait, not just a location.
struct MapScreen: View {
    @Environment(VenueStore.self) private var store
    @Environment(AppModel.self) private var app
    @Environment(LocationService.self) private var location

    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.5524, longitude: 7.0182),
            span: MKCoordinateSpan(latitudeDelta: 0.011, longitudeDelta: 0.011)
        )
    )
    @State private var selectedID: String?
    @State private var path = NavigationPath()

    private var ranked: [RankedVenue] {
        store.ranked(from: location.origin, preferences: app.preferences)
    }

    var body: some View {
        NavigationStack(path: $path) {
            let items = ranked
            ZStack(alignment: .bottom) {
                Map(position: $camera) {
                    UserAnnotation()
                    if location.isUsingDemoLocation {
                        Annotation("You", coordinate: location.origin.clLocation, anchor: .center) {
                            OriginMarker()
                        }
                        .annotationTitles(.hidden)
                    }
                    ForEach(items) { item in
                        Annotation(item.venue.name, coordinate: item.venue.coordinate.clLocation, anchor: .bottom) {
                            MapWaitMarker(item: item, isSelected: selectedID == item.id)
                                .onTapGesture { select(item) }
                        }
                        .annotationTitles(.hidden)
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .onTapGesture {
                    withAnimation(.snappy) { selectedID = nil }
                }

                VStack {
                    topOverlay(items)
                    Spacer()
                    if let selected = items.first(where: { $0.id == selectedID }) {
                        MapVenueCard(
                            item: selected,
                            onDetails: { path.append(selected.id) },
                            onGo: { app.startJourney(to: selected) },
                            onClose: { withAnimation(.snappy) { selectedID = nil } }
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { venueID in
                VenueDetailView(venueID: venueID)
            }
        }
    }

    private func select(_ item: RankedVenue) {
        Haptics.tap()
        withAnimation(.snappy) {
            selectedID = item.id
            camera = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: item.venue.coordinate.latitude - 0.0018,
                        longitude: item.venue.coordinate.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                )
            )
        }
    }

    private func topOverlay(_ items: [RankedVenue]) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                LiveDot()
                Text("Live · \(items.filter { $0.venue.isOpen() }.count) places open")
                    .font(YCFont.subheadlineMedium)
                Spacer()
                Text(YCFormat.relative(store.lastUpdated))
                    .font(YCFont.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: Capsule())

            HStack(spacing: 12) {
                legend(color: YC.Palette.fast, label: "≤ 5 min")
                legend(color: YC.Palette.moderate, label: "6–12 min")
                legend(color: YC.Palette.busy, label: "13+ min")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(YCFont.caption).foregroundStyle(.secondary)
        }
    }
}

struct OriginMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(YC.Palette.brand.opacity(0.2))
                .frame(width: 34, height: 34)
            Circle()
                .fill(YC.Palette.brand)
                .frame(width: 14, height: 14)
                .overlay(Circle().strokeBorder(.white, lineWidth: 3))
        }
    }
}

struct MapWaitMarker: View {
    let item: RankedVenue
    let isSelected: Bool

    private var isOpen: Bool { item.venue.isOpen() }
    private var color: Color { isOpen ? YC.waitColor(item.prediction.waitMinutes) : Color.gray }

    var body: some View {
        VStack(spacing: -3) {
            HStack(spacing: 5) {
                Image(systemName: item.venue.category.symbol)
                    .font(.system(size: 11, weight: .bold))
                Text(isOpen ? "\(item.prediction.waitMinutes)m" : "Closed")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color, in: Capsule())
            .overlay(Capsule().strokeBorder(.white, lineWidth: 2))
            .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundStyle(color)
        }
        .scaleEffect(isSelected ? 1.18 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct MapVenueCard: View {
    let item: RankedVenue
    let onDetails: () -> Void
    let onGo: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VenueArtwork(venue: item.venue, cornerRadius: 14, symbolSize: 22)
                    .frame(width: 64, height: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.venue.name)
                        .font(YCFont.headline)
                    Text("\(item.venue.category.label) · \(item.walkMinutes) min walk · \(item.venue.priceLabel)")
                        .font(YCFont.footnote)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        WaitPill(minutes: item.prediction.waitMinutes)
                        ConfidenceDots(confidence: item.prediction.confidence)
                    }
                }
                Spacer(minLength: 0)
                Button {
                    Haptics.tap()
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(YC.Palette.fill, in: Circle())
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 10) {
                PrimaryButton(title: "Details", symbol: "info.circle", kind: .outline, action: onDetails)
                PrimaryButton(title: "Go now", symbol: "figure.walk", kind: .ink, action: onGo)
            }
        }
        .ycCard()
    }
}
