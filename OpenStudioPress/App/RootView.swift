import SwiftUI

@MainActor
struct RootView: View {
    @Environment(StudioAppStore.self) private var store

    private let dependencies: AppDependencies
    @State private var router: StartupRouter

    init(dependencies: AppDependencies, router: StartupRouter? = nil) {
        self.dependencies = dependencies
        _router = State(initialValue: router ?? StartupRouter(dependencies: dependencies))
    }

    var body: some View {
        @Bindable var store = store

        Group {
            switch router.phase {
            case .warming:
                StudioWarmupView()
            case .native:
                if store.hasCompletedOnboarding {
                    NavigationStack(path: $store.path) {
                        TabView(selection: $store.selectedTab) {
                            CreateBriefScreen(dependencies: dependencies)
                                .tabItem {
                                    Label("Create", systemImage: "square.and.pencil")
                                }
                                .tag(StudioTab.create)

                            LibraryGridScreen(dependencies: dependencies)
                                .tabItem {
                                    Label("Library", systemImage: "books.vertical")
                                }
                                .tag(StudioTab.library)

                            TemplatesGalleryScreen(dependencies: dependencies)
                                .tabItem {
                                    Label("Templates", systemImage: "rectangle.stack")
                                }
                                .tag(StudioTab.templates)

                            SettingsScreen(dependencies: dependencies)
                                .tabItem {
                                    Label("Settings", systemImage: "gearshape")
                                }
                                .tag(StudioTab.settings)
                        }
                        .tint(AppTheme.accent)
                        .toolbar(store.path.isEmpty ? .hidden : .automatic, for: .navigationBar)
                        .navigationDestination(for: StudioRoute.self, destination: pushDestination)
                    }
                    .sheet(item: $store.sheetRoute, content: sheetDestination)
                } else {
                    OnboardingScreen()
                }
            case .experiment(let webView):
                ExperimentWebViewWrapper(webView: webView)
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.phase.isWarming)
        .sensoryFeedback(.impact(weight: .light), trigger: router.phase.isWarming)
        .task { await router.start() }
        .onChange(of: store.selectedTab) { oldTab, newTab in
            guard oldTab != newTab else { return }
            Task { @MainActor in
                store.clearNavigation()
            }
        }
        .onChange(of: store.hasCompletedOnboarding) { _, hasCompletedOnboarding in
            guard !hasCompletedOnboarding else { return }
            store.clearNavigation()
        }
        .onChange(of: store.sheetRoute) { _, sheetRoute in
            guard sheetRoute == nil else { return }
            store.handleSheetDismissed()
        }
    }

    @ViewBuilder
    private func pushDestination(for route: StudioRoute) -> some View {
        switch route {
        case .blockShelf:
            BlockShelfScreen(dependencies: dependencies)
        case .arranger:
            StopArrangerScreen(compositionEngine: dependencies.compositionEngine)
        case .preview:
            LiveBookletPreviewScreen(dependencies: dependencies)
        case let .artifactDetail(artifactID):
            ArtifactDetailScreen(artifactID: artifactID, dependencies: dependencies)
        case let .templateDetail(templateID):
            TemplateDetailScreen(templateID: templateID, dependencies: dependencies)
        case .layoutControls, .healthPanel, .duplicateSetup, .export:
            EmptyView()
        }
    }

    @ViewBuilder
    private func sheetDestination(for route: StudioRoute) -> some View {
        switch route {
        case .layoutControls:
            InkLayoutControlsScreen(compositionEngine: dependencies.compositionEngine)
        case .healthPanel:
            CompositionHealthPanelScreen(dependencies: dependencies)
        case let .duplicateSetup(artifactID):
            DuplicateSetupScreen(artifactID: artifactID, dependencies: dependencies)
        case let .export(artifactID):
            ExportBookletScreen(artifactID: artifactID, dependencies: dependencies)
        case .blockShelf, .arranger, .preview, .artifactDetail, .templateDetail:
            EmptyView()
        }
    }
}

extension StudioRoute: Identifiable {
    var id: String {
        switch self {
        case let .blockShelf(identifier):
            "blockShelf-\(identifier)"
        case let .arranger(identifier):
            "arranger-\(identifier)"
        case let .layoutControls(identifier):
            "layoutControls-\(identifier)"
        case let .preview(identifier):
            "preview-\(identifier)"
        case let .healthPanel(identifier):
            "healthPanel-\(identifier)"
        case let .artifactDetail(identifier):
            "artifactDetail-\(identifier)"
        case let .templateDetail(identifier):
            "templateDetail-\(identifier)"
        case let .duplicateSetup(identifier):
            "duplicateSetup-\(identifier)"
        case let .export(identifier):
            "export-\(identifier)"
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    RootView(dependencies: dependencies, router: .previewNative())
        .environment(dependencies.store)
}
