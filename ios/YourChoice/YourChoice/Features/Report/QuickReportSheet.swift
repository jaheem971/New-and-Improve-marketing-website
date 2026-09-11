import SwiftUI

/// One-tap wait reporting. A report is a real-time correction, a validation
/// point and, eventually, a training signal.
struct QuickReportSheet: View {
    let venue: Venue

    @Environment(\.dismiss) private var dismiss
    @Environment(VenueStore.self) private var store
    @Environment(AppModel.self) private var app

    @State private var submitted: WaitReportOption?

    var body: some View {
        VStack(spacing: 20) {
            if let submitted {
                success(submitted)
            } else {
                form
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(YC.Palette.canvas)
        .presentationDetents([.height(470)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("How's the wait at")
                    .font(YCFont.subheadline)
                    .foregroundStyle(.secondary)
                Text(venue.name)
                    .font(YCFont.display(28))
                Text("One tap. It corrects the estimate for everyone nearby and earns you 10 points.")
                    .font(YCFont.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WaitReportOption.allCases) { option in
                    Button {
                        submit(option)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: option.symbol)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(YC.waitColor(option.minutes))
                            Text(option.title)
                                .font(YCFont.headline)
                            Text(option.subtitle)
                                .font(YCFont.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(YC.Palette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }

            let prediction = store.prediction(for: venue)
            Text("Currently showing \(prediction.waitLabel) · \(YCFormat.freshness(prediction.freshness).lowercased())")
                .font(YCFont.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func success(_ option: WaitReportOption) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(YC.Palette.fast.opacity(0.15))
                    .frame(width: 88, height: 88)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(YC.Palette.fast)
            }
            Text("Thanks. That helps everyone.")
                .font(YCFont.title)
            Text("+10 points")
                .font(YCFont.headline)
                .foregroundStyle(YC.Palette.brand)
            Text("Your \"\(option.title)\" report is now blended into the live estimate for \(venue.name).")
                .font(YCFont.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    private func submit(_ option: WaitReportOption) {
        Haptics.success()
        store.submitReport(venueID: venue.id, minutes: option.minutes)
        app.recordReport(isConfirmation: false)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            submitted = option
        }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            dismiss()
        }
    }
}
