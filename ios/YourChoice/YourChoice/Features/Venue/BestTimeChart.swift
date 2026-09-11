import Charts
import SwiftUI

/// Best-time-to-go, driven by the venue's historical pattern. A Pro feature
/// in the revenue model; the demo unlocks it with one tap.
struct BestTimeCard: View {
    let venue: Venue
    let isPro: Bool
    let onUnlock: () -> Void

    private struct Point: Identifiable {
        let hour: Int
        let minutes: Double
        var id: Int { hour }
    }

    private var points: [Point] {
        (venue.opensAt..<venue.closesAt).map { hour in
            Point(hour: hour, minutes: venue.history.expectedWait(atHour: hour, on: .now))
        }
    }

    private var nowHour: Int { Calendar.current.component(.hour, from: .now) }

    private var bestUpcoming: Point? {
        points.filter { $0.hour > nowHour }.min { $0.minutes < $1.minutes }
    }

    private var axisValues: [Double] {
        stride(from: venue.opensAt, to: venue.closesAt, by: 3).map(Double.init)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Best time to go")
                        .font(YCFont.headline)
                    Text("Typical wait by hour, today")
                        .font(YCFont.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                BadgeLabel(text: "Pro", symbol: "crown.fill", tint: YC.Palette.moderate)
            }

            ZStack {
                Chart(points) { point in
                    BarMark(
                        x: .value("Hour", Double(point.hour)),
                        y: .value("Wait", point.minutes),
                        width: .fixed(12)
                    )
                    .foregroundStyle(barColor(for: point))
                    .cornerRadius(4)
                }
                .chartXScale(domain: Double(venue.opensAt) - 0.6 ... Double(venue.closesAt) - 0.4)
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: axisValues) { value in
                        AxisValueLabel {
                            if let hour = value.as(Double.self) {
                                Text(YCFormat.hourLabel(Int(hour)))
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                            }
                        }
                    }
                }
                .frame(height: 140)
                .blur(radius: isPro ? 0 : 6)
                .opacity(isPro ? 1 : 0.55)

                if !isPro {
                    VStack(spacing: 10) {
                        Text("Unlock best-time predictions, history and alerts")
                            .font(YCFont.subheadlineMedium)
                            .multilineTextAlignment(.center)
                        PrimaryButton(title: "Try YourChoice Pro", symbol: "crown.fill", kind: .ink, fullWidth: false, action: onUnlock)
                    }
                    .padding(.horizontal, 12)
                }
            }

            if isPro {
                HStack(spacing: 14) {
                    legend(color: YC.Palette.brand, label: "Now")
                    legend(color: YC.Palette.fast, label: "Calmest later")
                    Spacer()
                }
                if let best = bestUpcoming {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(YC.Palette.fast)
                        Text("Calmest later today around \(YCFormat.hourLabel(best.hour)) (~\(Int(best.minutes.rounded())) min)")
                            .font(YCFont.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .ycCard()
    }

    private func barColor(for point: Point) -> Color {
        if point.hour == nowHour { return YC.Palette.brand }
        if point.hour == bestUpcoming?.hour { return YC.Palette.fast }
        return YC.Palette.fillStrong
    }

    private func legend(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 10, height: 10)
            Text(label).font(YCFont.caption).foregroundStyle(.secondary)
        }
    }
}
