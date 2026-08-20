import Foundation

extension Artifact {
    convenience init(id: String, title: String, size: BookletSize, density: ReadingDensity, foldRhythm: FoldRhythm, blockIDs: [String], createdAt: Date) {
        self.init(id: id, title: title, size: size, density: density, foldRhythm: foldRhythm, blockIDs: blockIDs, blockSnapshots: [], createdAt: createdAt)
    }
}

final class SeededArtifactRepository: ArtifactRepository {
    private struct ArtifactRecord: Codable {
        var id: String
        var title: String
        var size: BookletSize
        var density: ReadingDensity
        var foldRhythm: FoldRhythm
        var blockIDs: [String]
        var blockSnapshots: [ArtifactBlockSnapshot]
        var createdAt: Date

        init(artifact: Artifact) {
            id = artifact.id
            title = artifact.title
            size = artifact.size
            density = artifact.density
            foldRhythm = artifact.foldRhythm
            blockIDs = artifact.blockIDs
            blockSnapshots = artifact.blockSnapshots
            createdAt = artifact.createdAt
        }

        func materializedArtifact() -> Artifact {
            Artifact(id: id, title: title, size: size, density: density, foldRhythm: foldRhythm, blockIDs: blockIDs, blockSnapshots: blockSnapshots, createdAt: createdAt)
        }
    }

    private var storedArtifacts: [Artifact]
    private let defaults: UserDefaults?
    private let storageKey: String

    init(artifacts: [Artifact] = StudioSeedData.artifacts()) {
        defaults = nil
        storageKey = ""
        storedArtifacts = Self.hydratedArtifacts(artifacts)
    }

    init(defaults: UserDefaults, storageKey: String = "openStudioPress.artifacts.v1") {
        self.defaults = defaults
        self.storageKey = storageKey
        if defaults.object(forKey: storageKey) == nil {
            storedArtifacts = Self.hydratedArtifacts(StudioSeedData.artifacts())
            persist()
        } else if let encoded = defaults.data(forKey: storageKey), let records = try? JSONDecoder().decode([ArtifactRecord].self, from: encoded) {
            storedArtifacts = records.map { $0.materializedArtifact() }
        } else {
            storedArtifacts = []
        }
    }

    func artifacts() -> [Artifact] { storedArtifacts }
    func artifact(id: String) -> Artifact? { storedArtifacts.first { $0.id == id } }
    func snapshots(artifactID: String) -> [ArtifactBlockSnapshot] {
        storedArtifacts.first { $0.id == artifactID }?.blockSnapshots.sorted { $0.order < $1.order } ?? []
    }
    func save(artifact: Artifact) -> Void {
        artifact.blockSnapshots.sort { $0.order < $1.order }
        artifact.blockIDs = artifact.blockSnapshots.map(\.id)
        if let index = storedArtifacts.firstIndex(where: { $0.id == artifact.id }) {
            storedArtifacts[index] = artifact
        } else {
            storedArtifacts.append(artifact)
        }
        persist()
    }
    func resetArtifacts() -> Void {
        storedArtifacts = []
        persist()
    }

    private func persist() {
        let records = storedArtifacts.map(ArtifactRecord.init)
        if let encoded = try? JSONEncoder().encode(records) {
            defaults?.set(encoded, forKey: storageKey)
        }
    }

    private static func hydratedArtifacts(_ artifacts: [Artifact]) -> [Artifact] {
        let catalog = Dictionary(uniqueKeysWithValues: StudioSeedData.blocks().map { ($0.id, $0) })
        for artifact in artifacts where artifact.blockSnapshots.isEmpty {
            artifact.blockSnapshots = artifact.blockIDs.compactMap { catalog[$0] }.map(ArtifactBlockSnapshot.init)
        }
        return artifacts
    }
}

final class MemoryOnboardingStateStore: OnboardingStateStore {
    private var completed: Bool
    init(completed: Bool = false) { self.completed = completed }
    func hasCompletedOnboarding() -> Bool { completed }
    func setCompletedOnboarding(_ completed: Bool) -> Void { self.completed = completed }
}

final class UserDefaultsOnboardingStateStore: OnboardingStateStore {
    private let defaults: UserDefaults
    private let storageKey: String
    private let initialPreference = OnboardingPreference(id: "pref-onboarding", completed: false, revision: 1)
    init(defaults: UserDefaults, storageKey: String = "openStudioPress.onboarding.completed") {
        self.defaults = defaults
        self.storageKey = storageKey
    }
    func hasCompletedOnboarding() -> Bool {
        defaults.object(forKey: storageKey) == nil ? initialPreference.completed : defaults.bool(forKey: storageKey)
    }
    func setCompletedOnboarding(_ completed: Bool) -> Void {
        defaults.set(completed, forKey: storageKey)
    }
}

final class SeededTemplateRepository: TemplateRepository {
    private let storedTemplates: [Template]
    init(templates: [Template] = StudioSeedData.templates()) { storedTemplates = templates }
    func templates() -> [Template] { storedTemplates }
    func template(id: String) -> Template? { storedTemplates.first { $0.id == id } }
}

final class SeededBlockCatalog: BlockCatalog {
    private let storedBlocks: [Block]
    private let storedKinds: [BlockKindDescriptor]
    init(blocks: [Block] = StudioSeedData.blocks(), kinds: [BlockKindDescriptor] = StudioSeedData.blockKinds()) {
        storedBlocks = blocks
        storedKinds = kinds
    }
    func blockKinds() -> [BlockKindDescriptor] { storedKinds }
    func blocks() -> [Block] { storedBlocks }
    func block(id: String) -> Block? { storedBlocks.first { $0.id == id } }
}

struct DeterministicExportDocumentService: ExportDocumentService {
    func plainText(output: CompositionOutput) -> ExportDocument {
        ExportDocument(id: "export-text-\(output.id)", format: .plainText, filename: "visitor-guide.txt", bytes: Array(output.visitorText.utf8))
    }

    func printPDF(output: CompositionOutput) -> ExportDocument {
        let content = pdfContentStream(output: output)
        let objects = [
            "<< /Type /Catalog /Pages 2 0 R >>",
            "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
            "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>",
            "<< /Length \(content.utf8.count) >>\nstream\n\(content)\nendstream",
            "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"
        ]
        var bytes = Array("%PDF-1.4\n%OSP\n".utf8)
        var offsets: [Int] = []
        for (index, object) in objects.enumerated() {
            offsets.append(bytes.count)
            bytes.append(contentsOf: Array("\(index + 1) 0 obj\n\(object)\nendobj\n".utf8))
        }
        let xrefOffset = bytes.count
        var xref = "xref\n0 \(objects.count + 1)\n0000000000 65535 f \n"
        for offset in offsets {
            xref += String(format: "%010d 00000 n \n", offset)
        }
        xref += "trailer\n<< /Size \(objects.count + 1) /Root 1 0 R >>\nstartxref\n\(xrefOffset)\n%%EOF\n"
        bytes.append(contentsOf: Array(xref.utf8))
        return ExportDocument(id: "export-pdf-\(output.id)", format: .printPDF, filename: "visitor-guide.pdf", bytes: bytes)
    }

    private func pdfContentStream(output: CompositionOutput) -> String {
        let source = "Open Studio Press " + output.visitorText
        let words = source.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        var lines: [String] = []
        var current = ""
        for word in words {
            let candidate = current.isEmpty ? word : current + " " + word
            if candidate.count > 72 {
                if !current.isEmpty { lines.append(current) }
                current = String(word.prefix(72))
            } else {
                current = candidate
            }
            if lines.count == 39 { break }
        }
        if !current.isEmpty && lines.count < 40 { lines.append(current) }
        var commands = ["BT", "/F1 11 Tf", "50 742 Td", "14 TL"]
        for line in lines {
            commands.append("(\(escapedPDFText(line))) Tj")
            commands.append("T*")
        }
        commands.append("ET")
        return commands.joined(separator: "\n")
    }

    private func escapedPDFText(_ text: String) -> String {
        var escaped = ""
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 40, 41, 92:
                escaped.append("\\")
                escaped.append(contentsOf: String(scalar))
            case 32...126:
                escaped.append(contentsOf: String(scalar))
            default:
                escaped.append(" ")
            }
        }
        return escaped
    }
}
