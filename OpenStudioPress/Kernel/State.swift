import Foundation
import Observation

@MainActor
@Observable
final class StudioAppStore {
    var selectedTab: StudioTab
    var hasCompletedOnboarding: Bool {
        didSet { onboardingState.setCompletedOnboarding(hasCompletedOnboarding) }
    }
    var brief: CreateBrief
    var draftBlocks: [Block]
    var composition: CompositionOutput?
    var path: [StudioRoute] = []
    var sheetRoute: StudioRoute?
    private var pendingPush: StudioRoute?
    @ObservationIgnored private let onboardingState: any OnboardingStateStore

    init(selectedTab: StudioTab = .create, hasCompletedOnboarding: Bool? = nil, brief: CreateBrief = CreateBrief(id: "draft-current", title: "Untitled Booklet", size: .halfLetter, templateID: nil, density: .balanced, foldRhythm: .paired), draftBlocks: [Block] = [], composition: CompositionOutput? = nil, onboardingState: any OnboardingStateStore = MemoryOnboardingStateStore()) {
        self.selectedTab = selectedTab
        self.onboardingState = onboardingState
        self.hasCompletedOnboarding = hasCompletedOnboarding ?? onboardingState.hasCompletedOnboarding()
        self.brief = brief
        self.draftBlocks = draftBlocks
        self.composition = composition
    }

    func navigate(_ route: StudioRoute) {
        switch route {
        case .layoutControls, .healthPanel, .duplicateSetup, .export:
            if sheetRoute == route {
                sheetRoute = nil
                return
            }
            sheetRoute = route
        default:
            if sheetRoute != nil {
                pendingPush = route
                sheetRoute = nil
                return
            }
            guard path.last != route else { return }
            var updatedPath = path
            updatedPath.append(route)
            path = updatedPath
        }
    }

    func clearNavigation() {
        path = []
        sheetRoute = nil
        pendingPush = nil
    }

    func openCreateArranger(briefID: String) {
        clearNavigation()
        selectedTab = .create
        path = [.arranger(briefID)]
    }

    func handleSheetDismissed() {
        guard let pendingPush else { return }
        self.pendingPush = nil
        navigate(pendingPush)
    }

    func resetForDeletion() {
        selectedTab = .create
        hasCompletedOnboarding = false
        brief = CreateBrief(id: "draft-current", title: "Untitled Booklet", size: .halfLetter, templateID: nil, density: .balanced, foldRhythm: .paired)
        draftBlocks = []
        composition = nil
        clearNavigation()
    }
}

enum StudioTab: String, Codable, Hashable, CaseIterable {
    case create, library, templates, settings
}

enum StudioRoute: Hashable {
    /// Push destinations carry only stable ids — brief payload lives on `StudioAppStore`.
    case blockShelf(String)
    case arranger(String)
    case layoutControls(String)
    case preview(String)
    case healthPanel(String)
    case artifactDetail(String)
    case templateDetail(String)
    case duplicateSetup(String)
    case export(String)
}

struct DraftBooklet: Identifiable {
    var id: String
    var brief: CreateBrief
    var blocks: [Block]
}
