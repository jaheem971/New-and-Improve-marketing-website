import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// YourChoice design tokens. Adaptive system surfaces keep dark mode free.
enum YC {
    enum Palette {
        static let brand = Color(hex: 0x4F46E5)
        static let brandDeep = Color(hex: 0x312E81)
        static let brandGlow = Color(hex: 0x8B5CF6)
        static let ink = Color(hex: 0x0B0F19)
        static let inkSoft = Color(hex: 0x1C2333)
        static let cream = Color(hex: 0xFBF7F1)

        static let fast = Color(hex: 0x16A34A)
        static let moderate = Color(hex: 0xF59E0B)
        static let busy = Color(hex: 0xE11D48)

        static let canvas = Color(uiColor: .systemGroupedBackground)
        static let surface = Color(uiColor: .secondarySystemGroupedBackground)
        static let surfaceRaised = Color(uiColor: .systemBackground)
        static let fill = Color(uiColor: .tertiarySystemFill)
        static let fillStrong = Color(uiColor: .secondarySystemFill)
        static let separator = Color(uiColor: .separator)
    }

    enum Radius {
        static let card: CGFloat = 24
        static let inner: CGFloat = 18
        static let button: CGFloat = 18
        static let chip: CGFloat = 14
    }

    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    static func waitColor(_ minutes: Int) -> Color {
        if minutes <= 5 { return Palette.fast }
        if minutes <= 12 { return Palette.moderate }
        return Palette.busy
    }

    static func waitTone(_ minutes: Int) -> String {
        if minutes <= 5 { return "Fast" }
        if minutes <= 12 { return "Moderate" }
        return "Busy"
    }

    static let heroGradient = LinearGradient(
        colors: [Palette.brandDeep, Palette.ink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let brandGradient = LinearGradient(
        colors: [Palette.brand, Palette.brandGlow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum YCFont {
    static func display(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title2, design: .rounded, weight: .bold)
    static let title3 = Font.system(.title3, design: .rounded, weight: .semibold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .rounded)
    static let bodyMedium = Font.system(.body, design: .rounded, weight: .medium)
    static let subheadline = Font.system(.subheadline, design: .rounded)
    static let subheadlineMedium = Font.system(.subheadline, design: .rounded, weight: .semibold)
    static let caption = Font.system(.caption, design: .rounded, weight: .medium)
    static let captionBold = Font.system(.caption, design: .rounded, weight: .bold)
    static let footnote = Font.system(.footnote, design: .rounded)
    static func number(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
}

/// Gradient artwork stands in for venue photography in the MVP.
enum VenueArtworkPalette {
    static let sets: [[Color]] = [
        [Color(hex: 0xF97316), Color(hex: 0xC2410C)],
        [Color(hex: 0x0EA5E9), Color(hex: 0x1D4ED8)],
        [Color(hex: 0x10B981), Color(hex: 0x047857)],
        [Color(hex: 0xA16207), Color(hex: 0x713F12)],
        [Color(hex: 0x8B5CF6), Color(hex: 0x4C1D95)],
        [Color(hex: 0xF59E0B), Color(hex: 0xB45309)],
        [Color(hex: 0x64748B), Color(hex: 0x1E293B)],
        [Color(hex: 0x06B6D4), Color(hex: 0x0E7490)],
        [Color(hex: 0xEC4899), Color(hex: 0x9D174D)],
        [Color(hex: 0xD97706), Color(hex: 0x92400E)],
        [Color(hex: 0xEF4444), Color(hex: 0x991B1B)],
        [Color(hex: 0x6366F1), Color(hex: 0x312E81)],
    ]

    static func gradient(_ index: Int) -> LinearGradient {
        let colors = sets[abs(index) % sets.count]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Card treatment

struct CardModifier: ViewModifier {
    var padding: CGFloat
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(YC.Palette.surface, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 6)
    }
}

extension View {
    func ycCard(padding: CGFloat = YC.Space.lg, radius: CGFloat = YC.Radius.card) -> some View {
        modifier(CardModifier(padding: padding, radius: radius))
    }
}

// MARK: - Formatting

enum YCFormat {
    static func freshness(_ seconds: TimeInterval?) -> String {
        guard let seconds else { return "Based on typical pattern" }
        if seconds < 60 { return "Updated just now" }
        let minutes = Int(seconds / 60)
        if minutes < 60 { return "Updated \(minutes) min ago" }
        return "Updated \(minutes / 60) h ago"
    }

    static func relative(_ date: Date) -> String {
        let seconds = Date.now.timeIntervalSince(date)
        if seconds < 60 { return "Just now" }
        let minutes = Int(seconds / 60)
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours) h ago" }
        return "\(hours / 24) d ago"
    }

    static func clock(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func hourLabel(_ hour: Int) -> String {
        String(format: "%02d:00", hour)
    }
}
