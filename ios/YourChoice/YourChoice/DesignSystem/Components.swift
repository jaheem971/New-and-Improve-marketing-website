import SwiftUI

// MARK: - Wait pill

struct WaitPill: View {
    let minutes: Int
    var prominent: Bool = false

    private var color: Color { YC.waitColor(minutes) }
    private var text: String { minutes <= 1 ? "No wait" : "~\(minutes) min" }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(text)
                .font(prominent ? YCFont.subheadlineMedium : YCFont.captionBold)
        }
        .foregroundStyle(color)
        .padding(.horizontal, prominent ? 12 : 10)
        .padding(.vertical, prominent ? 7 : 5)
        .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Confidence

struct ConfidenceDots: View {
    let confidence: Confidence
    var tint: Color = YC.Palette.brand
    var showsLabel: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index < confidence.filledDots ? tint : tint.opacity(0.2))
                        .frame(width: 10, height: 4)
                }
            }
            if showsLabel {
                Text(confidence.shortLabel)
                    .font(YCFont.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel(confidence.label)
    }
}

// MARK: - Live dot

struct LiveDot: View {
    var color: Color = YC.Palette.fast

    var body: some View {
        Image(systemName: "circle.fill")
            .font(.system(size: 8))
            .foregroundStyle(color)
            .symbolEffect(.pulse, options: .repeating)
    }
}

// MARK: - Freshness

struct FreshnessLabel: View {
    let prediction: Prediction
    var color: Color = .secondary

    var body: some View {
        HStack(spacing: 5) {
            if prediction.freshness != nil {
                LiveDot(color: color == .secondary ? YC.Palette.fast : color)
            } else {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(YCFormat.freshness(prediction.freshness))
                .font(YCFont.caption)
        }
        .foregroundStyle(color)
    }
}

// MARK: - Trend

struct TrendLabel: View {
    let prediction: Prediction

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: prediction.trend.symbol)
                .font(.system(size: 10, weight: .bold))
            Text(deltaText)
                .font(YCFont.caption)
        }
        .foregroundStyle(.secondary)
    }

    private var deltaText: String {
        let delta = prediction.deltaVsUsual
        if abs(delta) <= 1 { return "About usual" }
        return delta < 0 ? "\(abs(delta)) min under usual" : "\(delta) min over usual"
    }
}

// MARK: - Attribute chip

struct AttributeChip: View {
    let attribute: VenueAttribute
    var isSelected: Bool = false
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: attribute.symbol)
                .font(.system(size: compact ? 10 : 12, weight: .semibold))
            if !compact {
                Text(attribute.shortLabel)
                    .font(YCFont.caption)
            }
        }
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .padding(.horizontal, compact ? 7 : 10)
        .padding(.vertical, compact ? 5 : 7)
        .background(isSelected ? YC.Palette.brand : YC.Palette.fill, in: Capsule())
    }
}

// MARK: - Selectable chip

struct FilterChip: View {
    let title: String
    var symbol: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(title)
                    .font(YCFont.subheadlineMedium)
            }
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(isSelected ? YC.Palette.ink : YC.Palette.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(YC.Palette.separator.opacity(isSelected ? 0 : 0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Buttons

enum PrimaryButtonStyleKind {
    case brand, ink, white, tinted, outline
}

struct PrimaryButton: View {
    let title: String
    var symbol: String? = nil
    var kind: PrimaryButtonStyleKind = .brand
    var fullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.firm()
            action()
        } label: {
            HStack(spacing: 8) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(YCFont.headline)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .foregroundStyle(foreground)
            .background(background, in: RoundedRectangle(cornerRadius: YC.Radius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: YC.Radius.button, style: .continuous)
                    .strokeBorder(kind == .outline ? YC.Palette.separator : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var foreground: Color {
        switch kind {
        case .brand, .ink: return .white
        case .white: return YC.Palette.ink
        case .tinted: return YC.Palette.brand
        case .outline: return .primary
        }
    }

    private var background: Color {
        switch kind {
        case .brand: return YC.Palette.brand
        case .ink: return YC.Palette.ink
        case .white: return .white
        case .tinted: return YC.Palette.brand.opacity(0.12)
        case .outline: return YC.Palette.surface
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct IconButton: View {
    let symbol: String
    var tint: Color = .primary
    var background: Color = YC.Palette.surface
    var badge: Int = 0
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(background, in: Circle())
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(YC.Palette.busy, in: Capsule())
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(YCFont.title3)
                if let subtitle {
                    Text(subtitle)
                        .font(YCFont.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(YCFont.subheadlineMedium)
                    .foregroundStyle(YC.Palette.brand)
            }
        }
    }
}

// MARK: - Venue artwork

struct VenueArtwork: View {
    let venue: Venue
    var cornerRadius: CGFloat = YC.Radius.inner
    var symbolSize: CGFloat = 28

    var body: some View {
        ZStack {
            VenueArtworkPalette.gradient(venue.artworkIndex)
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 140, height: 140)
                .offset(x: 50, y: -50)
            Circle()
                .fill(.black.opacity(0.10))
                .frame(width: 120, height: 120)
                .offset(x: -55, y: 55)
            Image(systemName: venue.category.symbol)
                .font(.system(size: symbolSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Stat tile

struct StatTile: View {
    let value: String
    let label: String
    var symbol: String? = nil
    var tint: Color = YC.Palette.brand

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint)
            }
            Text(value)
                .font(YCFont.number(22))
            Text(label)
                .font(YCFont.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(YC.Palette.fill, in: RoundedRectangle(cornerRadius: YC.Radius.inner, style: .continuous))
    }
}

// MARK: - Info row

struct InfoRow: View {
    let symbol: String
    let title: String
    var detail: String? = nil
    var tint: Color = YC.Palette.brand

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(YCFont.bodyMedium)
                if let detail {
                    Text(detail)
                        .font(YCFont.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Rating

struct RatingLabel: View {
    let rating: Double
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(YC.Palette.moderate)
            Text(String(format: "%.1f", rating))
                .font(YCFont.caption)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Badge

struct BadgeLabel: View {
    let text: String
    var symbol: String? = nil
    var tint: Color = YC.Palette.brand

    var body: some View {
        HStack(spacing: 4) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 9, weight: .bold))
            }
            Text(text.uppercased())
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(0.6)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.14), in: Capsule())
    }
}
