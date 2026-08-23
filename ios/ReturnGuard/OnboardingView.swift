import SwiftUI

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "calendar.badge.clock",
        title: "Never miss a return deadline again.",
        subtitle: "ReturnGuard keeps the clock on every purchase so you don't have to."
    ),
    OnboardingPage(
        icon: "doc.text.viewfinder",
        title: "Snap your receipt.",
        subtitle: "We automatically organize the important details — store, price, dates."
    ),
    OnboardingPage(
        icon: "bell.badge.fill",
        title: "We'll remind you before it's too late.",
        subtitle: "One reminder, seven days out. Nothing else."
    ),
]

/// The three-slide intro from the design's "Onboarding" turn. Shown once,
/// gated by `AppRootView`'s persisted flag — no account, sign-up, or
/// sign-in involved, matching the "No account needed" line on its last
/// page (and echoed later in Settings and the add-purchase sheet).
struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            // Deliberately not TabView(selection:) with .page style: it
            // handles swipes fine but is unreliable when the page is
            // changed programmatically (as the Continue button below does)
            // — confirmed in testing, where swiping advanced correctly but
            // tapping Continue silently did nothing.
            ZStack {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    if index == page {
                        OnboardingPageView(page: onboardingPages[index])
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 18) {
                HStack(spacing: 6) {
                    ForEach(onboardingPages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == page ? RG.accent : RG.ink.opacity(0.16))
                            .frame(width: index == page ? 18 : 6, height: 6)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: page)

                Button {
                    if page < onboardingPages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(page == onboardingPages.count - 1 ? "Get started" : "Continue")
                        .font(.rgHeading(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(RG.accent))
                        .shadow(color: RG.accent.opacity(0.32), radius: 12, x: 0, y: 6)
                }

                if page == onboardingPages.count - 1 {
                    Text("No account needed")
                        .font(.rgBody(13))
                        .foregroundStyle(RG.textTertiary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 26)
        }
        .background(RG.background.ignoresSafeArea())
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle().fill(RG.accentTint).frame(width: 168, height: 168)
                Image(systemName: page.icon)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(RG.accent)
            }
            Spacer().frame(height: 44)
            Text(page.title)
                .font(.rgHeading(27))
                .foregroundStyle(RG.ink)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            Text(page.subtitle)
                .font(.rgBody(15))
                .foregroundStyle(RG.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            Spacer()
            Spacer()
        }
    }
}
