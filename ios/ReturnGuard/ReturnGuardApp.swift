import SwiftUI
import SwiftData

@main
struct ReturnGuardApp: App {
    init() {
        // Keeps the Settings toggle's declared default (true) in sync with
        // NotificationManager's raw UserDefaults read, which otherwise
        // defaults to false until the key is written once.
        UserDefaults.standard.register(defaults: [NotificationManager.notificationsEnabledKey: true])
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: Purchase.self)
    }
}
