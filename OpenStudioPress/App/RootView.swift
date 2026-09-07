import SwiftUI

struct RootView: View {
    private let dependencies: AppDependencies
    @Bindable private var store: StudioAppStore
    @State private var launch: AppLaunch
    @StateObject private var appCover = AppCover()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @MainActor
    init(dependencies: AppDependencies, launch: AppLaunch? = nil) {
        self.dependencies = dependencies
        store = dependencies.store
        _launch = State(initialValue: launch ?? AppLaunch(dependencies: dependencies))
    }

    var body: some View {
        ZStack {
            if let webView = displayedWeb {
                coveredWebView(webView)
                    .scaleEffect(webSettleScale)
            } else if case .native = launch.phase {
                nativeShell
            } else {
                AppTheme.bgBase.ignoresSafeArea()
            }

            if appCover.isCoverVisible {
                StudioCover()
                    .transition(.opacity)
                    .contentShape(Rectangle())
                    .onTapGesture { appCover.deactivateImmediately() }
            }
        }
        .overlay {
            loaderOverlay
        }
        .environment(store)
        .tint(AppTheme.accent)
        .sensoryFeedback(.impact(weight: .medium), trigger: launch.loaderProgress >= 1)
        .task { await launch.start() }
        .onChange(of: scenePhase) { _, phase in
            appCover.handleScenePhase(phase)
        }
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

    private var webSettleScale: CGFloat {
        guard launch.phase.isLoading || launch.coverOpacity > 0.02 else { return 1 }
        return 1 + CGFloat(launch.coverOpacity) * 0.018
    }

    private var displayedWeb: WebViewController? {
        if case .web(let webView) = launch.phase { return webView }
        return launch.pendingWeb
    }

    private var revealAnimation: Animation? {
        guard !reduceMotion else { return nil }
        return .timingCurve(0.16, 1.0, 0.3, 1.0, duration: revealDuration)
    }

    private var revealDuration: TimeInterval {
        switch launch.coverStyle {
        case .scrim: return Timeouts.warmScrimMax
        case .warm: return Timeouts.warmRevealCrossfade
        case .branded, .invisible: return Timeouts.revealCrossfade
        }
    }

    @ViewBuilder
    private var loaderOverlay: some View {
        let veil = launch.coverOpacity
        Group {
            switch launch.phase {
            case .loading:
                switch launch.coverStyle {
                case .branded:
                    BrandedSplash(progress: launch.loaderProgress, veil: veil)
                case .warm:
                    WarmOverlay(progress: launch.loaderProgress, veil: veil)
                case .scrim:
                    WarmScrim(progress: launch.loaderProgress, veil: veil)
                case .invisible:
                    Color.clear
                }
            default:
                EmptyView()
            }
        }
        .animation(revealAnimation, value: veil)
    }

    private func coveredWebView(_ webView: WebViewController) -> some View {
        WebViewScreen(webView: webView)
            .ignoresSafeArea()
            .animation(revealAnimation, value: launch.coverOpacity)
    }

    @ViewBuilder
    private var nativeShell: some View {
        if store.hasCompletedOnboarding {
            tabShell
        } else {
            OnboardingScreen()
        }
    }

    private var tabShell: some View {
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
            .sensoryFeedback(.selection, trigger: store.selectedTab)
            .toolbar(store.path.isEmpty ? .hidden : .automatic, for: .navigationBar)
            .navigationDestination(for: StudioRoute.self, destination: pushDestination)
        }
        .background(AppTheme.bgBase)
        .sheet(item: $store.sheetRoute, content: sheetDestination)
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
    RootView(dependencies: .preview(), launch: .previewNative())
}
