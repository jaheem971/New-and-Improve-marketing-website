import MapKit
import SwiftUI

/// The journey from home to venue. The estimate keeps updating on the way,
/// and the app speaks up if a materially better option appears.
struct JourneyView: View {
    let start: RankedVenue

    @Environment(VenueStore.self) private var store
    @Environment(AppModel.self) private var app
    @Environment(LocationService.self) private var location

    @State private var camera: MapCameraPosition = .automatic
    @State private var progress: Double = 0
    @State private var arrived = false
    @State private var switchDismissed = false
    @State private var confirmed = false

    private var live: RankedVenue {
        store.rankedItem(id: start.id, from: location.origin, preferences: app.preferences) ?? start
    }

    private var betterOption: RankedVenue? {
        guard app.preferences.betterOptionAlerts, !switchDismissed, !arrived else { return nil }
        let current = live
        let ranked = store.ranked(from: location.origin, preferences: app.preferences)
        guard let best = ranked.first, best.id != current.id, best.venue.isOpen() else { return nil }
        return current.totalMinutes - best.totalMinutes >= 4 ? best : nil
    }

    private var remainingWalk: Int {
        arrived ? 0 : Int((Double(start.walkMinutes) * (1 - progress)).rounded(.up))
    }

    private var eta: Date { Date.now.addingTimeInterval(TimeInterval(remainingWalk * 60)) }

    var body: some View {
        let current = live
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        LiveDot(color: arrived ? YC.Palette.brand : YC.Palette.fast)
                        Text(arrived ? "You're here" : "On your way")
                            .font(YCFont.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(start.venue.name)
                        .font(YCFont.display(26))
                }
                Spacer()
                IconButton(symbol: "xmark") { app.endJourney() }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Map(position: $camera) {
                Annotation("Start", coordinate: location.origin.clLocation, anchor: .center) {
                    OriginMarker()
                }
                .annotationTitles(.hidden)
                Annotation(start.venue.name, coordinate: start.venue.coordinate.clLocation, anchor: .bottom) {
                    MapWaitMarker(item: current, isSelected: true)
                }
                .annotationTitles(.hidden)
                MapPolyline(coordinates: [location.origin.clLocation, start.venue.coordinate.clLocation])
                    .stroke(YC.Palette.brand, style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [10, 8]))
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    if let better = betterOption {
                        BetterOptionBanner(
                            better: better,
                            current: current,
                            onSwitch: {
                                Haptics.success()
                                app.startJourney(to: better)
                            },
                            onKeep: {
                                withAnimation(.snappy) { switchDismissed = true }
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    liveCard(current)
                    progressCard

                    if arrived && !confirmed {
                        confirmCard
                            .transition(.scale(scale: 0.96).combined(with: .opacity))
                    } else if confirmed {
                        thanksCard
                    } else {
                        PrimaryButton(title: "I've arrived", symbol: "mappin.and.ellipse", kind: .outline) {
                            withAnimation(.snappy) {
                                progress = 1
                                arrived = true
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .background(YC.Palette.canvas)
        .task { await simulateWalk() }
    }

    // MARK: - Cards

    private func liveCard(_ current: RankedVenue) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Live at \(current.venue.name)")
                    .font(YCFont.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(current.prediction.waitMinutes)")
                        .font(YCFont.number(44))
                        .foregroundStyle(YC.waitColor(current.prediction.waitMinutes))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: current.prediction.waitMinutes)
                    Text(current.prediction.waitMinutes <= 1 ? "no wait" : "min wait")
                        .font(YCFont.subheadline)
                        .foregroundStyle(.secondary)
                }
                FreshnessLabel(prediction: current.prediction)
                TrendLabel(prediction: current.prediction)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(arrived ? "Arrived" : "ETA")
                    .font(YCFont.caption)
                    .foregroundStyle(.secondary)
                Text(YCFormat.clock(eta))
                    .font(YCFont.number(24))
                ConfidenceDots(confidence: current.prediction.confidence)
            }
        }
        .ycCard()
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(YC.Palette.brand)
                Text(arrived ? "You made it" : "\(remainingWalk) min left")
                    .font(YCFont.headline)
                Spacer()
                Text("\(start.walkMinutes) min walk")
                    .font(YCFont.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progress)
                .tint(YC.Palette.brand)
            Text(arrived
                 ? "Confirm the wait below to sharpen the model for the next person."
                 : "We'll keep watching. If the queue jumps or a better option opens up, you'll know.")
                .font(YCFont.footnote)
                .foregroundStyle(.secondary)
        }
        .ycCard()
    }

    private var confirmCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How's the wait actually?")
                .font(YCFont.headline)
            Text("A confirmation on arrival is our best ground truth. +15 points.")
                .font(YCFont.footnote)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(WaitReportOption.allCases) { option in
                    Button {
                        Haptics.success()
                        store.submitReport(venueID: start.id, minutes: option.minutes, isConfirmation: true)
                        app.recordReport(isConfirmation: true)
                        withAnimation(.snappy) { confirmed = true }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: option.symbol)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(YC.waitColor(option.minutes))
                            Text(option.title)
                                .font(YCFont.captionBold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(YC.Palette.fill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .ycCard()
    }

    private var thanksCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(YC.Palette.fast)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Confirmed. +15 points")
                        .font(YCFont.headline)
                    Text("Enjoy \(start.venue.name).")
                        .font(YCFont.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            PrimaryButton(title: "Done", kind: .ink) { app.endJourney() }
        }
        .ycCard()
    }

    // MARK: - Simulation

    /// Simulates the walk for the demo: one real minute of walking is
    /// compressed to five seconds so the journey screen can be exercised.
    private func simulateWalk() async {
        let totalSeconds = max(20, Double(start.walkMinutes) * 5)
        let step = 0.5 / totalSeconds
        while !Task.isCancelled && !arrived {
            try? await Task.sleep(for: .milliseconds(500))
            if arrived { break }
            withAnimation(.linear(duration: 0.5)) {
                progress = min(1, progress + step)
            }
            if progress >= 1 {
                Haptics.success()
                withAnimation(.snappy) { arrived = true }
            }
        }
    }
}

struct BetterOptionBanner: View {
    let better: RankedVenue
    let current: RankedVenue
    let onSwitch: () -> Void
    let onKeep: () -> Void

    private var saved: Int { current.totalMinutes - better.totalMinutes }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "arrow.triangle.swap")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Heads up: \(better.venue.name) is \(saved) min faster now")
                        .font(YCFont.headline)
                        .foregroundStyle(.white)
                    Text("\(better.walkMinutes) min walk · \(better.prediction.waitLabel) · \(better.prediction.confidence.shortLabel.lowercased()) confidence")
                        .font(YCFont.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            HStack(spacing: 10) {
                Button {
                    Haptics.tap()
                    onKeep()
                } label: {
                    Text("Keep going")
                        .font(YCFont.subheadlineMedium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
                Button {
                    onSwitch()
                } label: {
                    Text("Switch")
                        .font(YCFont.subheadlineMedium)
                        .foregroundStyle(YC.Palette.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(16)
        .background(YC.brandGradient, in: RoundedRectangle(cornerRadius: YC.Radius.card, style: .continuous))
        .shadow(color: YC.Palette.brand.opacity(0.3), radius: 16, y: 8)
    }
}
