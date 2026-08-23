import SwiftUI

/// Shows the onboarding intro once (persisted flag), then the real app.
struct AppRootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                RootView()
                    .transition(.opacity)
            } else {
                OnboardingView {
                    withAnimation { hasSeenOnboarding = true }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasSeenOnboarding)
    }
}
