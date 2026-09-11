import SwiftUI

struct VenueDetailView: View {
    let venueID: String

    @Environment(VenueStore.self) private var store
    @Environment(AppModel.self) private var app
    @Environment(LocationService.self) private var location

    @State private var showReport = false
    @State private var showSignals = false

    var body: some View {
        if let item = store.rankedItem(id: venueID, from: location.origin, preferences: app.preferences) {
            content(item)
        } else {
            ContentUnavailableView("Venue not found", systemImage: "mappin.slash")
        }
    }

    private func content(_ item: RankedVenue) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                hero(item)
                LivePredictionCard(item: item)
                whyCard(item)
                BestTimeCard(venue: item.venue, isPro: app.user.isPro) {
                    Haptics.success()
                    app.setPro(true)
                }
                attributesCard(item.venue)
                infoCard(item.venue)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(YC.Palette.canvas)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.tap()
                    app.toggleFavorite(item.id)
                } label: {
                    Image(systemName: app.isFavorite(item.id) ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(app.isFavorite(item.id) ? YC.Palette.busy : Color.white)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        .safeAreaInset(edge: .bottom) { actionBar(item) }
        .sheet(isPresented: $showReport) { QuickReportSheet(venue: item.venue) }
    }

    // MARK: - Hero

    private func hero(_ item: RankedVenue) -> some View {
        ZStack(alignment: .bottomLeading) {
            VenueArtwork(venue: item.venue, cornerRadius: 0, symbolSize: 72)
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    BadgeLabel(text: item.venue.category.label, symbol: item.venue.category.symbol, tint: .white)
                    if item.venue.isPartner {
                        BadgeLabel(text: "Live partner", symbol: "bolt.fill", tint: Color(hex: 0xA7F3D0))
                    }
                }
                Text(item.venue.name)
                    .font(YCFont.display(32))
                    .foregroundStyle(.white)
                HStack(spacing: 8) {
                    RatingLabel(rating: item.venue.rating, color: .white)
                    Text("·").foregroundStyle(.white.opacity(0.6))
                    Text(item.venue.priceLabel)
                    Text("·").foregroundStyle(.white.opacity(0.6))
                    Text("\(item.walkMinutes) min walk")
                    Text("·").foregroundStyle(.white.opacity(0.6))
                    Text(item.venue.isOpen() ? "Open" : "Closed")
                        .foregroundStyle(item.venue.isOpen() ? Color(hex: 0xA7F3D0) : Color(hex: 0xFECDD3))
                }
                .font(YCFont.caption)
                .foregroundStyle(.white.opacity(0.9))
            }
            .padding(20)
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, -16)
    }

    // MARK: - Why this estimate

    private func whyCard(_ item: RankedVenue) -> some View {
        let prediction = item.prediction
        return VStack(alignment: .leading, spacing: 12) {
            Button {
                Haptics.tap()
                withAnimation(.snappy) { showSignals.toggle() }
            } label: {
                HStack {
                    InfoRow(
                        symbol: "brain.head.profile",
                        title: "Why this estimate",
                        detail: summary(for: item)
                    )
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(showSignals ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if showSignals {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                    ForEach(prediction.sources, id: \.self) { source in
                        HStack(spacing: 12) {
                            Image(systemName: source.symbol)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(YC.Palette.brand)
                                .frame(width: 26)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(source.label).font(YCFont.subheadlineMedium)
                                Text(source.detail).font(YCFont.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(signalCount(for: source, in: item.venue))")
                                .font(YCFont.captionBold)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(YC.Palette.fill, in: Capsule())
                        }
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(YC.Palette.brand)
                            .frame(width: 26)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Typical for now").font(YCFont.subheadlineMedium)
                            Text("Baseline from this venue's history").font(YCFont.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("~\(prediction.baselineMinutes) min")
                            .font(YCFont.captionBold)
                            .foregroundStyle(.secondary)
                    }
                    Text("Signals are timestamped and lose influence as they age. Consistently accurate contributors carry more weight; suspicious repeats carry less.")
                        .font(YCFont.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .ycCard()
    }

    private func summary(for item: RankedVenue) -> String {
        let count = item.prediction.liveSignalCount
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let day = formatter.string(from: .now)
        if count == 0 { return "No live signal yet. Showing the usual \(day) pattern." }
        return "\(count) live signal\(count == 1 ? "" : "s") blended with the usual \(day) pattern"
    }

    private func signalCount(for source: SignalSource, in venue: Venue) -> Int {
        venue.signals.filter { $0.source == source && Date.now.timeIntervalSince($0.timestamp) <= 45 * 60 }.count
    }

    // MARK: - Attributes

    private func attributesCard(_ venue: Venue) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Good to know")
                .font(YCFont.headline)
            if venue.attributes.isEmpty {
                Text("No extras listed yet.")
                    .font(YCFont.footnote)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                    ForEach(venue.attributes.sorted { $0.rawValue < $1.rawValue }) { attribute in
                        HStack(spacing: 8) {
                            Image(systemName: attribute.symbol)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(YC.Palette.brand)
                                .frame(width: 22)
                            Text(attribute.label)
                                .font(YCFont.subheadline)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .ycCard()
    }

    // MARK: - Info

    private func infoCard(_ venue: Venue) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            InfoRow(symbol: "mappin.and.ellipse", title: venue.address, detail: "Cannes")
            InfoRow(symbol: "clock.fill", title: venue.hoursLabel, detail: venue.isOpen() ? "Open now" : "Closed now")
            if venue.isPartner {
                InfoRow(symbol: "bolt.fill", title: "Live partner venue", detail: "Signals flow straight from the till. No staff data-entry needed.", tint: YC.Palette.fast)
            } else {
                InfoRow(symbol: "storefront", title: "Own this place?", detail: "Connect your POS for live analytics and free customer acquisition.", tint: .secondary)
            }
        }
        .ycCard()
    }

    // MARK: - Actions

    private func actionBar(_ item: RankedVenue) -> some View {
        HStack(spacing: 10) {
            PrimaryButton(title: "Report wait", symbol: "hand.raised.fill", kind: .outline) {
                showReport = true
            }
            PrimaryButton(title: "Go now", symbol: "figure.walk", kind: .ink) {
                app.startJourney(to: item)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}

/// The one simple output: wait, confidence, freshness, crowd and seats.
struct LivePredictionCard: View {
    let item: RankedVenue

    private var prediction: Prediction { item.prediction }
    private var isOpen: Bool { item.venue.isOpen() }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    LiveDot(color: isOpen ? YC.Palette.fast : .gray)
                    Text(isOpen ? "Live now" : "Closed now")
                        .font(YCFont.headline)
                }
                Spacer()
                BadgeLabel(
                    text: prediction.kindLabel,
                    symbol: prediction.isObserved ? "eye.fill" : "wand.and.stars",
                    tint: prediction.isObserved ? YC.Palette.fast : YC.Palette.moderate
                )
            }

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(prediction.waitMinutes)")
                    .font(YCFont.number(60))
                    .foregroundStyle(YC.waitColor(prediction.waitMinutes))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: prediction.waitMinutes)
                Text(prediction.waitMinutes <= 1 ? "no wait" : "min wait")
                    .font(YCFont.title3)
                    .foregroundStyle(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    ConfidenceDots(confidence: prediction.confidence)
                    FreshnessLabel(prediction: prediction)
                }
            }

            Divider()

            HStack(spacing: 0) {
                miniStat(symbol: prediction.crowd.symbol, value: prediction.crowd.label, label: "Crowd")
                miniStat(symbol: "chair.fill", value: prediction.seatingLikely ? "Likely" : "Unlikely", label: "Seats")
                miniStat(symbol: prediction.trend.symbol, value: prediction.trend.shortLabel, label: "Trend")
                miniStat(symbol: "clock.arrow.circlepath", value: usualText, label: "vs usual")
            }
        }
        .ycCard()
    }

    private var usualText: String {
        let delta = prediction.deltaVsUsual
        if abs(delta) <= 1 { return "Same" }
        return delta < 0 ? "−\(abs(delta)) min" : "+\(delta) min"
    }

    private func miniStat(symbol: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(YC.Palette.brand)
            Text(value)
                .font(YCFont.subheadlineMedium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(YCFont.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
