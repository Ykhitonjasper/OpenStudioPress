import SwiftUI

@MainActor
struct RootView: View {
    @Environment(StudioAppStore.self) private var store

    private let dependencies: AppDependencies
    @State private var navigationPath: [StudioRoute] = []
    @State private var presentedSheet: StudioRoute?
    @State private var pendingPush: StudioRoute?

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    var body: some View {
        @Bindable var store = store

        Group {
            if store.hasCompletedOnboarding {
                NavigationStack(path: $navigationPath) {
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
                    .navigationDestination(for: StudioRoute.self, destination: pushDestination)
                }
                .sheet(item: sheetBinding, content: sheetDestination)
            } else {
                OnboardingScreen()
            }
        }
        .onChange(of: store.route) { _, route in
            guard let route else { return }
            present(route)
        }
        .onChange(of: store.hasCompletedOnboarding) { _, hasCompletedOnboarding in
            guard !hasCompletedOnboarding else { return }
            navigationPath = []
            presentedSheet = nil
            pendingPush = nil
            store.route = nil
        }
        .onChange(of: presentedSheet) { _, sheet in
            guard sheet == nil, let pendingPush else { return }
            self.pendingPush = nil
            if navigationPath.last != pendingPush {
                navigationPath.append(pendingPush)
            }
        }
    }

    private var sheetBinding: Binding<StudioRoute?> {
        Binding(
            get: { presentedSheet },
            set: { presentedSheet = $0 }
        )
    }

    private func present(_ route: StudioRoute) {
        switch route {
        case .layoutControls, .healthPanel, .duplicateSetup, .export:
            if presentedSheet == route {
                store.route = nil
                return
            }
            presentedSheet = route
        case .blockShelf, .arranger, .preview, .artifactDetail, .templateDetail:
            if navigationPath.last == route || pendingPush == route {
                store.route = nil
                return
            }
            if presentedSheet == nil {
                navigationPath.append(route)
            } else {
                pendingPush = route
                presentedSheet = nil
            }
        }
        store.route = nil
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

    RootView(dependencies: dependencies)
        .environment(dependencies.store)
}
