import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var app
    @Environment(LocationService.self) private var location

    @State private var page = 0
    @State private var priority: RankingPriority = .balanced

    private let pageCount = 3

    var body: some View {
        ZStack {
            YC.heroGradient.ignoresSafeArea()
            Circle()
                .fill(YC.Palette.brandGlow.opacity(0.25))
                .frame(width: 420, height: 420)
                .blur(radius: 60)
                .offset(x: 140, y: -260)

            VStack(spacing: 24) {
                HStack {
                    Text("YOURCHOICE")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    if page < pageCount - 1 {
                        Button("Skip") { withAnimation { page = pageCount - 1 } }
                            .font(YCFont.subheadlineMedium)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                TabView(selection: $page) {
                    OnboardingPage(
                        symbol: "sparkles",
                        title: "Know before you go.",
                        text: "YourChoice ranks nearby cafés by what you'd actually experience right now: predicted wait, walking time and the things you care about."
                    )
                    .tag(0)

                    OnboardingPage(
                        symbol: "antenna.radiowaves.left.and.right",
                        title: "We know, so you don't have to report.",
                        text: "Live venue signals, aggregated on-device patterns and history feed one prediction with a confidence level. We only ask you when the system isn't sure."
                    )
                    .tag(1)

                    prioritiesPage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        Capsule()
                            .fill(.white.opacity(index == page ? 1 : 0.3))
                            .frame(width: index == page ? 22 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }

                PrimaryButton(title: buttonTitle, symbol: page == pageCount - 1 ? "location.fill" : nil, kind: .white) {
                    if page < pageCount - 1 {
                        withAnimation { page += 1 }
                    } else {
                        finish()
                    }
                }

                Text("Location is used to rank places by walking time. It's never stored in identifiable form.")
                    .font(YCFont.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .opacity(page == pageCount - 1 ? 1 : 0)
            }
            .padding(24)
        }
    }

    private var buttonTitle: String {
        if page < pageCount - 1 { return "Continue" }
        return location.isAuthorized ? "Start exploring" : "Enable location & start"
    }

    private var prioritiesPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer(minLength: 0)
            Text("What matters most right now?")
                .font(YCFont.display(30))
                .foregroundStyle(.white)
            Text("You can change this any time. It shapes how we rank places for you.")
                .font(YCFont.body)
                .foregroundStyle(.white.opacity(0.7))

            VStack(spacing: 10) {
                ForEach(RankingPriority.allCases) { option in
                    Button {
                        Haptics.selection()
                        priority = option
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: option.symbol)
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(priority == option ? 0.25 : 0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.label).font(YCFont.headline)
                                Text(option.blurb).font(YCFont.footnote).opacity(0.7)
                            }
                            Spacer()
                            Image(systemName: priority == option ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .opacity(priority == option ? 1 : 0.4)
                        }
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(.white.opacity(priority == option ? 0.16 : 0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(.white.opacity(priority == option ? 0.6 : 0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func finish() {
        app.updatePreferences { $0.priority = priority }
        location.requestAccess()
        Haptics.success()
        app.completeOnboarding()
    }
}

private struct OnboardingPage: View {
    let symbol: String
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.white.opacity(0.12))
                    .frame(width: 112, height: 112)
                Image(systemName: symbol)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(YCFont.display(36))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text(text)
                .font(YCFont.body)
                .foregroundStyle(.white.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
