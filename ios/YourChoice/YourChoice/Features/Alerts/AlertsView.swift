import SwiftUI

struct AlertsView: View {
    @Environment(AppModel.self) private var app
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if app.alerts.isEmpty {
                    ContentUnavailableView("No alerts yet", systemImage: "bell.slash", description: Text("We'll let you know when a favourite gets quiet or a better option appears on your way."))
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(app.alerts) { alert in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: alert.kind.symbol)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(YC.Palette.brand)
                                        .frame(width: 36, height: 36)
                                        .background(YC.Palette.brand.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(alert.title)
                                                .font(YCFont.headline)
                                            Spacer()
                                            if !alert.isRead {
                                                Circle().fill(YC.Palette.brand).frame(width: 8, height: 8)
                                            }
                                        }
                                        Text(alert.message)
                                            .font(YCFont.footnote)
                                            .foregroundStyle(.secondary)
                                        Text(YCFormat.relative(alert.date))
                                            .font(YCFont.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .ycCard(padding: 14)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(YC.Palette.canvas)
            .navigationTitle("Alerts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(YCFont.subheadlineMedium)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .onDisappear { app.markAlertsRead() }
    }
}
