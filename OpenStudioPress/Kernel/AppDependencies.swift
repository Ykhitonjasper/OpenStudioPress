import Foundation

@MainActor
struct AppDependencies {
    let artifacts: any ArtifactRepository
    let onboardingState: any OnboardingStateStore
    let templates: any TemplateRepository
    let blockCatalog: any BlockCatalog
    let compositionEngine: any CompositionEngine
    let exportDocuments: any ExportDocumentService
    let store: StudioAppStore
    let analyticsCoordinator: AnalyticsCoordinating
    let analyticsSession: AnalyticsSessionProviding

    init(
        artifacts: any ArtifactRepository,
        onboardingState: any OnboardingStateStore,
        templates: any TemplateRepository,
        blockCatalog: any BlockCatalog,
        compositionEngine: any CompositionEngine,
        exportDocuments: any ExportDocumentService,
        store: StudioAppStore,
        analyticsCoordinator: AnalyticsCoordinating = AnalyticsCoordinator.shared,
        analyticsSession: AnalyticsSessionProviding = AnalyticsSession.shared
    ) {
        self.artifacts = artifacts
        self.onboardingState = onboardingState
        self.templates = templates
        self.blockCatalog = blockCatalog
        self.compositionEngine = compositionEngine
        self.exportDocuments = exportDocuments
        self.store = store
        self.analyticsCoordinator = analyticsCoordinator
        self.analyticsSession = analyticsSession
    }

    static func preview() -> AppDependencies {
        let onboardingState = MemoryOnboardingStateStore(completed: true)
        return AppDependencies(
            artifacts: SeededArtifactRepository(),
            onboardingState: onboardingState,
            templates: SeededTemplateRepository(),
            blockCatalog: SeededBlockCatalog(),
            compositionEngine: PureCompositionEngine(),
            exportDocuments: DeterministicExportDocumentService(),
            store: StudioAppStore(hasCompletedOnboarding: true, onboardingState: onboardingState)
        )
    }

    static func app() -> AppDependencies {
        let defaults = UserDefaults.standard
        let onboardingState = UserDefaultsOnboardingStateStore(defaults: defaults)
        return AppDependencies(
            artifacts: SeededArtifactRepository(defaults: defaults),
            onboardingState: onboardingState,
            templates: SeededTemplateRepository(),
            blockCatalog: SeededBlockCatalog(),
            compositionEngine: PureCompositionEngine(),
            exportDocuments: DeterministicExportDocumentService(),
            store: StudioAppStore(onboardingState: onboardingState)
        )
    }
}
