import SwiftUI

extension Trend {
    var shortLabel: String {
        switch self {
        case .rising: return "Rising"
        case .steady: return "Steady"
        case .falling: return "Easing"
        }
    }
}

// MARK: - Best choice hero

struct BestChoiceHero: View {
    let item: RankedVenue
    let onOpen: () -> Void
    let onGo: () -> Void

    private var arrival: Date { Date.now.addingTimeInterval(TimeInterval(item.walkMinutes * 60)) }
    private var inHand: Date { arrival.addingTimeInterval(TimeInterval(item.prediction.waitMinutes * 60)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                BadgeLabel(text: "Best choice right now", symbol: "sparkles", tint: Color(hex: 0xC7D2FE))
                Spacer()
                FreshnessLabel(prediction: item.prediction, color: .white.opacity(0.75))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.venue.name)
                    .font(YCFont.display(28))
                    .foregroundStyle(.white)
                Text(item.venue.tagline)
                    .font(YCFont.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }

            HStack(alignment: .lastTextBaseline, spacing: 22) {
                heroStat(value: "\(item.prediction.waitMinutes)", unit: item.prediction.waitMinutes <= 1 ? "no wait" : "min wait", tint: YC.waitColor(item.prediction.waitMinutes))
                heroStat(value: "\(item.walkMinutes)", unit: "min walk", tint: .white)
                heroStat(value: YCFormat.clock(inHand), unit: "in hand by", tint: .white)
            }

            if !item.reasons.isEmpty {
                HStack(spacing: 6) {
                    ForEach(item.reasons, id: \.self) { reason in
                        Text(reason)
                            .font(YCFont.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.14), in: Capsule())
                    }
                }
            }

            HStack {
                ConfidenceDots(confidence: item.prediction.confidence, tint: .white)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    Haptics.firm()
                    onGo()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 14, weight: .bold))
                        Text("Go now")
                            .font(YCFont.headline)
                    }
                    .foregroundStyle(YC.Palette.ink)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(.white, in: Capsule())
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(22)
        .background(
            ZStack(alignment: .topTrailing) {
                YC.heroGradient
                Circle()
                    .fill(YC.Palette.brandGlow.opacity(0.35))
                    .frame(width: 220, height: 220)
                    .blur(radius: 40)
                    .offset(x: 60, y: -80)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: YC.Palette.brandDeep.opacity(0.35), radius: 24, y: 12)
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onTapGesture {
            Haptics.tap()
            onOpen()
        }
    }

    private func heroStat(value: String, unit: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(YCFont.number(30))
                .foregroundStyle(tint)
            Text(unit)
                .font(YCFont.caption)
                .foregroundStyle(.white.opacity(0.65))
        }
    }
}

// MARK: - Human help card

/// "Know first. Ask only when necessary." Appears only for a venue where
/// automatic coverage is weak and the user is close enough to answer.
struct HumanHelpCard: View {
    let venue: Venue
    let onAnswer: (WaitReportOption) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(YC.Palette.moderate)
                    .frame(width: 38, height: 38)
                    .background(YC.Palette.moderate.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Quick one, if you're nearby")
                        .font(YCFont.headline)
                    Text("We're not confident about \(venue.name) right now. How's the wait?")
                        .font(YCFont.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Button {
                    Haptics.tap()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 28, height: 28)
                        .background(YC.Palette.fill, in: Circle())
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                ForEach(WaitReportOption.allCases) { option in
                    Button {
                        Haptics.success()
                        onAnswer(option)
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

            Text("+10 points · We only ask when the system needs help")
                .font(YCFont.caption)
                .foregroundStyle(.tertiary)
        }
        .ycCard()
    }
}

// MARK: - Venue card

struct VenueCardView: View {
    let item: RankedVenue
    let isFavorite: Bool
    let onFavorite: () -> Void

    private var isOpen: Bool { item.venue.isOpen() }
    private var attributes: [VenueAttribute] {
        Array(item.venue.attributes.sorted { $0.rawValue < $1.rawValue }.prefix(4))
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                VenueArtwork(venue: item.venue)
                if !isOpen {
                    RoundedRectangle(cornerRadius: YC.Radius.inner, style: .continuous)
                        .fill(.black.opacity(0.45))
                    Text("Closed")
                        .font(YCFont.captionBold)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 96, height: 96)

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.venue.name)
                            .font(YCFont.headline)
                            .lineLimit(1)
                        Text("\(item.venue.category.label) · \(item.venue.priceLabel) · \(item.walkMinutes) min walk")
                            .font(YCFont.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 6)
                    Button {
                        Haptics.tap()
                        onFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isFavorite ? YC.Palette.busy : Color.secondary)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 5) {
                    ForEach(attributes) { attribute in
                        AttributeChip(attribute: attribute, compact: true)
                    }
                    RatingLabel(rating: item.venue.rating)
                }

                HStack(spacing: 10) {
                    if isOpen {
                        WaitPill(minutes: item.prediction.waitMinutes)
                        TrendLabel(prediction: item.prediction)
                    } else {
                        Text("Opens \(item.venue.opensAt):00")
                            .font(YCFont.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    ConfidenceDots(confidence: item.prediction.confidence, showsLabel: false)
                }

                if isOpen {
                    FreshnessLabel(prediction: item.prediction)
                }
            }
        }
        .ycCard(padding: 12)
        .opacity(isOpen ? 1 : 0.75)
    }
}
