import SwiftUI

struct ProfileView: View {
    @Environment(AppModel.self) private var app

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    headerCard
                    statsRow
                    proCard
                    preferencesCard
                    alertsCard
                    leaderboardCard
                    aboutCard
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(YC.Palette.canvas)
            .navigationTitle("You")
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(YC.Palette.fill, lineWidth: 7)
                Circle()
                    .trim(from: 0, to: Double(app.user.reputation) / 100)
                    .stroke(YC.brandGradient, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(app.user.initials)
                    .font(YCFont.number(22))
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.user.name)
                    .font(YCFont.title)
                HStack(spacing: 6) {
                    BadgeLabel(text: app.user.tier, symbol: "checkmark.seal.fill", tint: YC.Palette.brand)
                    if app.user.isPro {
                        BadgeLabel(text: "Pro", symbol: "crown.fill", tint: YC.Palette.moderate)
                    }
                }
                Text("Reputation \(app.user.reputation)/100 · rewards accuracy, not volume")
                    .font(YCFont.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .ycCard()
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatTile(value: "\(app.user.points)", label: "Points", symbol: "star.fill", tint: YC.Palette.moderate)
            StatTile(value: "\(app.user.reportCount)", label: "Reports", symbol: "hand.raised.fill", tint: YC.Palette.brand)
            StatTile(value: "\(app.user.accuracyPercent)%", label: "Accuracy", symbol: "scope", tint: YC.Palette.fast)
        }
    }

    // MARK: - Pro

    private var proCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.user.isPro ? "YourChoice Pro is on" : "YourChoice Pro")
                        .font(YCFont.title3)
                        .foregroundStyle(.white)
                    Text(app.user.isPro ? "Thanks for backing the network." : "For people who go out a lot.")
                        .font(YCFont.footnote)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(hex: 0xFDE68A))
            }
            VStack(alignment: .leading, spacing: 8) {
                proFeature("clock.badge.checkmark", "Best-time-to-go predictions")
                proFeature("bell.badge.fill", "Quiet-now and on-route alerts")
                proFeature("slider.horizontal.3", "Advanced filters and history")
            }
            Button {
                Haptics.success()
                app.setPro(!app.user.isPro)
            } label: {
                Text(app.user.isPro ? "Manage Pro" : "Try Pro free for 14 days")
                    .font(YCFont.headline)
                    .foregroundStyle(YC.Palette.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(18)
        .background(YC.heroGradient, in: RoundedRectangle(cornerRadius: YC.Radius.card, style: .continuous))
        .shadow(color: YC.Palette.brandDeep.opacity(0.3), radius: 18, y: 10)
    }

    private func proFeature(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            Text(text)
                .font(YCFont.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    // MARK: - Preferences

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("How we rank for you")
                    .font(YCFont.headline)
                Text("From \"what's fastest?\" to \"what's best for me right now?\"")
                    .font(YCFont.footnote)
                    .foregroundStyle(.secondary)
            }

            PrioritySelector()
            Text(app.preferences.priority.blurb)
                .font(YCFont.caption)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Max walk")
                        .font(YCFont.subheadlineMedium)
                    Spacer()
                    Text("\(app.preferences.maxWalkMinutes) min")
                        .font(YCFont.subheadlineMedium)
                        .foregroundStyle(YC.Palette.brand)
                }
                Slider(value: maxWalkBinding, in: 3...25, step: 1)
                    .tint(YC.Palette.brand)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Must-haves")
                    .font(YCFont.subheadlineMedium)
                FlowChips(attributes: VenueAttribute.allCases, selected: app.preferences.mustHaves) { attribute in
                    Haptics.selection()
                    app.updatePreferences { preferences in
                        if preferences.mustHaves.contains(attribute) {
                            preferences.mustHaves.remove(attribute)
                        } else {
                            preferences.mustHaves.insert(attribute)
                        }
                    }
                }
            }
        }
        .ycCard()
    }

    private var maxWalkBinding: Binding<Double> {
        Binding(
            get: { Double(app.preferences.maxWalkMinutes) },
            set: { newValue in app.updatePreferences { $0.maxWalkMinutes = Int(newValue) } }
        )
    }

    // MARK: - Alerts

    private var alertsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alerts")
                .font(YCFont.headline)
            Toggle(isOn: preferenceBinding(\.favoriteQuietAlerts)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Favourite got quiet").font(YCFont.subheadlineMedium)
                    Text("When a saved place drops to a short wait").font(YCFont.caption).foregroundStyle(.secondary)
                }
            }
            .tint(YC.Palette.brand)
            Toggle(isOn: preferenceBinding(\.betterOptionAlerts)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Better option on the way").font(YCFont.subheadlineMedium)
                    Text("If somewhere materially faster opens up mid-journey").font(YCFont.caption).foregroundStyle(.secondary)
                }
            }
            .tint(YC.Palette.brand)
        }
        .ycCard()
    }

    private func preferenceBinding(_ keyPath: WritableKeyPath<DecisionPreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { app.preferences[keyPath: keyPath] },
            set: { newValue in app.updatePreferences { $0[keyPath: keyPath] = newValue } }
        )
    }

    // MARK: - Leaderboard

    private var leaderboardCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cannes scouts this week")
                    .font(YCFont.headline)
                Spacer()
                Text("Accuracy-weighted")
                    .font(YCFont.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(Array(app.leaderboard.enumerated()), id: \.element.id) { index, entry in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(YCFont.captionBold)
                        .foregroundStyle(index < 3 ? YC.Palette.moderate : Color.secondary)
                        .frame(width: 22)
                    Text(entry.name)
                        .font(entry.isYou ? YCFont.subheadlineMedium : YCFont.subheadline)
                        .foregroundStyle(entry.isYou ? YC.Palette.brand : Color.primary)
                    Spacer()
                    Text("\(entry.accuracy)%")
                        .font(YCFont.caption)
                        .foregroundStyle(.secondary)
                    Text("\(entry.points) pts")
                        .font(YCFont.subheadlineMedium)
                }
                .padding(.vertical, 4)
                if index < app.leaderboard.count - 1 { Divider() }
            }
        }
        .ycCard()
    }

    // MARK: - About

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Know first. Ask only when necessary.")
                .font(YCFont.headline)
            Text("Physical world → signals → intelligence → decision. YourChoice blends live venue signals, aggregated on-device patterns and history into one estimate with a confidence level. You are asked to help only when the system genuinely needs it.")
                .font(YCFont.footnote)
                .foregroundStyle(.secondary)
            Divider()
            InfoRow(symbol: "lock.shield.fill", title: "Privacy by design", detail: "Location signals are aggregated and never stored in identifiable form. No cameras are used in this release.", tint: YC.Palette.fast)
            InfoRow(symbol: "info.circle.fill", title: "YourChoice 1.0 · Cannes pilot", detail: "Know before you go.", tint: .secondary)
        }
        .ycCard()
    }
}

/// Wrapping row of attribute chips (a compact flow layout).
struct FlowChips: View {
    let attributes: [VenueAttribute]
    let selected: Set<VenueAttribute>
    let onToggle: (VenueAttribute) -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(attributes) { attribute in
                Button {
                    onToggle(attribute)
                } label: {
                    AttributeChip(attribute: attribute, isSelected: selected.contains(attribute))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
