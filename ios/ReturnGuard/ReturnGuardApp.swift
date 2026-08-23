import SwiftUI
import SwiftData

@main
struct ReturnGuardApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: Purchase.self)
    }
}
