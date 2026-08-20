import Foundation

protocol ArtifactRepository {
    func artifacts() -> [Artifact]
    func artifact(id: String) -> Artifact?
    func snapshots(artifactID: String) -> [ArtifactBlockSnapshot]
    func save(artifact: Artifact) -> Void
    func resetArtifacts() -> Void
}

protocol OnboardingStateStore {
    func hasCompletedOnboarding() -> Bool
    func setCompletedOnboarding(_ completed: Bool) -> Void
}

protocol TemplateRepository {
    func templates() -> [Template]
    func template(id: String) -> Template?
}

protocol BlockCatalog {
    func blockKinds() -> [BlockKindDescriptor]
    func blocks() -> [Block]
    func block(id: String) -> Block?
}

protocol CompositionEngine {
    func compose(brief: CreateBrief, blocks: [Block]) -> CompositionOutput
}

protocol ExportDocumentService {
    func plainText(output: CompositionOutput) -> ExportDocument
    func printPDF(output: CompositionOutput) -> ExportDocument
}
