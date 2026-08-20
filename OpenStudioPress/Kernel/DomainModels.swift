import Foundation
import SwiftData

// X@Model final class Artifact
@Model final class Artifact: Identifiable {
    @Attribute(.unique) var id: String
    var title: String
    var size: BookletSize
    var density: ReadingDensity
    var foldRhythm: FoldRhythm
    var blockIDs: [String]
    var blockSnapshots: [ArtifactBlockSnapshot]
    var createdAt: Date

    init(id: String, title: String, size: BookletSize, density: ReadingDensity, foldRhythm: FoldRhythm, blockIDs: [String], blockSnapshots: [ArtifactBlockSnapshot], createdAt: Date) {
        self.id = id
        self.title = title
        self.size = size
        self.density = density
        self.foldRhythm = foldRhythm
        self.blockIDs = blockIDs
        self.blockSnapshots = blockSnapshots.sorted { $0.order < $1.order }
        self.createdAt = createdAt
    }
}

// X@Model final class Template
@Model final class Template: Identifiable {
    @Attribute(.unique) var id: String
    var title: String
    var summary: String
    var size: BookletSize
    var density: ReadingDensity
    var blockIDs: [String]

    init(id: String, title: String, summary: String, size: BookletSize, density: ReadingDensity, blockIDs: [String]) {
        self.id = id
        self.title = title
        self.summary = summary
        self.size = size
        self.density = density
        self.blockIDs = blockIDs
    }
}

// X@Model final class Block
@Model final class Block: Identifiable {
    @Attribute(.unique) var id: String
    var kind: BlockKind
    var heading: String
    var body: String
    var order: Int
    var emphasis: Bool

    init(id: String, kind: BlockKind, heading: String, body: String, order: Int, emphasis: Bool) {
        self.id = id
        self.kind = kind
        self.heading = heading
        self.body = body
        self.order = order
        self.emphasis = emphasis
    }
}

struct ArtifactBlockSnapshot: Codable, Hashable, Identifiable {
    var id: String
    var kind: BlockKind
    var heading: String
    var body: String
    var order: Int
    var emphasis: Bool

    init(id: String, kind: BlockKind, heading: String, body: String, order: Int, emphasis: Bool) {
        self.id = id
        self.kind = kind
        self.heading = heading
        self.body = body
        self.order = order
        self.emphasis = emphasis
    }

    init(block: Block) {
        self.init(id: block.id, kind: block.kind, heading: block.heading, body: block.body, order: block.order, emphasis: block.emphasis)
    }

    func makeBlock() -> Block {
        Block(id: id, kind: kind, heading: heading, body: body, order: order, emphasis: emphasis)
    }
}

struct OnboardingPreference: Codable, Hashable, Identifiable {
    var id: String
    var completed: Bool
    var revision: Int
}

enum BlockKind: Codable, Hashable, CaseIterable {
    case coverMark, artistNote, exhibitStop, processWindow, materialCallout, lookingPrompt, studioEtiquette, takeHomeNote
    var code: String
    { String(describing: self) }
    var label: String {
        switch self {
        case .coverMark: "Cover Mark"
        case .artistNote: "Artist Note"
        case .exhibitStop: "Exhibit Stop"
        case .processWindow: "Process Window"
        case .materialCallout: "Material Callout"
        case .lookingPrompt: "Looking Prompt"
        case .studioEtiquette: "Studio Etiquette"
        case .takeHomeNote: "Take-Home Note"
        }
    }
    var rank: Int
    { Self.allCases.firstIndex(of: self) ?? 0 }
}

enum BookletSize: Codable, Hashable, CaseIterable {
    case pocket, halfLetter, square
    var code: String
    { String(describing: self) }
    var label: String { switch self { case .pocket: "Pocket"; case .halfLetter: "Half Letter"; case .square: "Square" } }
    var rank: Int
    { Self.allCases.firstIndex(of: self) ?? 0 }
}

enum ReadingDensity: Codable, Hashable, CaseIterable {
    case airy, balanced, detailed
    var code: String
    { String(describing: self) }
    var label: String { switch self { case .airy: "Airy"; case .balanced: "Balanced"; case .detailed: "Detailed" } }
    var rank: Int
    { Self.allCases.firstIndex(of: self) ?? 0 }
}

enum FoldRhythm: Codable, Hashable, CaseIterable {
    case single, paired, alternating
    var code: String
    { String(describing: self) }
    var label: String { switch self { case .single: "Single Pages"; case .paired: "Paired Spreads"; case .alternating: "Alternating Pace" } }
    var rank: Int
    { Self.allCases.firstIndex(of: self) ?? 0 }
}

enum StructuralFlag: Codable, Hashable, CaseIterable {
    case crowdedSpread, missingOrientation, unevenClosingPage
    var code: String
    { String(describing: self) }
    var label: String { switch self { case .crowdedSpread: "Crowded spread"; case .missingOrientation: "Add orientation"; case .unevenClosingPage: "Balance closing page" } }
    var rank: Int
    { Self.allCases.firstIndex(of: self) ?? 0 }
}

enum ExportFormat: Codable, Hashable, CaseIterable {
    case plainText, printPDF
    var code: String
    { String(describing: self) }
    var label: String { switch self { case .plainText: "Plain Text"; case .printPDF: "Print-ready PDF" } }
    var rank: Int
    { Self.allCases.firstIndex(of: self) ?? 0 }
}

struct CreateBrief: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var size: BookletSize
    var templateID: String?
    var density: ReadingDensity
    var foldRhythm: FoldRhythm
}

struct PageComposition: Codable, Hashable, Identifiable {
    var id: String
    var index: Int
    var blockIDs: [String]
    var characterCount: Int
    var crowded: Bool
}

struct CompositionOutput: Codable, Hashable, Identifiable {
    var id: String
    var pages: [PageComposition]
    var spreadGroups: [[String]]
    var rhythmScore: Double
    var densityScore: Double
    var estimatedVisitMinutes: Int
    var flags: [StructuralFlag]
    var visitorText: String
}

struct BlockKindDescriptor: Codable, Hashable, Identifiable {
    var id: String
    var kind: BlockKind
    var label: String
    var guidance: String
}

struct ExportDocument: Hashable, Identifiable {
    var id: String
    var format: ExportFormat
    var filename: String
    var bytes: [UInt8]
}
