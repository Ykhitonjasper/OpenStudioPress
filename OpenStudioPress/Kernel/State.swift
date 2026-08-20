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
    var route: StudioRoute?
    @ObservationIgnored private let onboardingState: any OnboardingStateStore

    init(selectedTab: StudioTab = .create, hasCompletedOnboarding: Bool? = nil, brief: CreateBrief = CreateBrief(id: "draft-current", title: "Untitled Booklet", size: .halfLetter, templateID: nil, density: .balanced, foldRhythm: .paired), draftBlocks: [Block] = [], composition: CompositionOutput? = nil, route: StudioRoute? = nil, onboardingState: any OnboardingStateStore = MemoryOnboardingStateStore()) {
        self.selectedTab = selectedTab
        self.onboardingState = onboardingState
        self.hasCompletedOnboarding = hasCompletedOnboarding ?? onboardingState.hasCompletedOnboarding()
        self.brief = brief
        self.draftBlocks = draftBlocks
        self.composition = composition
        self.route = route
    }

    func resetForDeletion() {
        selectedTab = .create
        hasCompletedOnboarding = false
        brief = CreateBrief(id: "draft-current", title: "Untitled Booklet", size: .halfLetter, templateID: nil, density: .balanced, foldRhythm: .paired)
        draftBlocks = []
        composition = nil
        route = nil
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
