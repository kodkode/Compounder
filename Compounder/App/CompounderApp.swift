import SwiftUI
import SwiftData

@main
struct CompounderApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .localizedEnvironment()
                .environmentObject(settings)
                .environmentObject(router)
                .onAppear { router.launch(hideAmounts: settings.hideAmountsOnLaunch) }
        }
        .modelContainer(for: Scenario.self)
    }
}
