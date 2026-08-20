import SwiftUI

@main
@MainActor
struct OpenStudioPressApp: App {
    @State private var dependencies = AppDependencies.app()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
                .environment(dependencies.store)
                .preferredColorScheme(.dark)
                .tint(AppTheme.accent)
        }
    }
}
