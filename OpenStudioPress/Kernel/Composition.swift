import Foundation

struct PureCompositionEngine: CompositionEngine {
    func compose(brief: CreateBrief, blocks: [Block]) -> CompositionOutput {
        let ordered = blocks.sorted { $0.order < $1.order }
        let blocksPerPage = brief.density == .airy ? 2 : (brief.density == .balanced ? 3 : 4)
        var pages: [PageComposition] = []
        var cursor = 0
        while cursor < ordered.count {
            let end = min(cursor + blocksPerPage, ordered.count)
            let slice = Array(ordered[cursor..<end])
            let characterCount = slice.reduce(0) { $0 + $1.heading.count + $1.body.count }
            pages.append(PageComposition(id: "page-\(pages.count + 1)", index: pages.count, blockIDs: slice.map(\.id), characterCount: characterCount, crowded: characterCount > 340))
            cursor = end
        }
        var spreadGroups: [[String]] = []
        switch brief.foldRhythm {
        case .single:
            spreadGroups = pages.map { [$0.id] }
        case .paired:
            for index in stride(from: 0, to: pages.count, by: 2) {
                let end = min(index + 2, pages.count)
                spreadGroups.append(Array(pages[index..<end]).map(\.id))
            }
        case .alternating:
            if let firstPage = pages.first { spreadGroups.append([firstPage.id]) }
            for index in stride(from: 1, to: pages.count, by: 2) {
                let end = min(index + 2, pages.count)
                spreadGroups.append(Array(pages[index..<end]).map(\.id))
            }
        }
        var flags: [StructuralFlag] = []
        if pages.contains(where: \.crowded) { flags.append(.crowdedSpread) }
        if ordered.first?.kind != .coverMark { flags.append(.missingOrientation) }
        if pages.last?.blockIDs.count == 1 && pages.count > 1 { flags.append(.unevenClosingPage) }
        let totalCharacters = pages.reduce(0) { $0 + $1.characterCount }
        let densityScore = pages.isEmpty ? 0 : Double(totalCharacters) / Double(pages.count)
        let rhythmBase = brief.foldRhythm == .paired ? 0.92 : (brief.foldRhythm == .alternating ? 0.84 : 0.76)
        let rhythmScore = max(0, rhythmBase - Double(flags.count) * 0.08)
        let visitMinutes = max(2, Int(ceil(Double(totalCharacters) / 420.0)) + ordered.filter { $0.kind == .lookingPrompt }.count * 2)
        let visitorText = ordered.map { "\($0.heading)\n\($0.body)" }.joined(separator: "\n\n")
        return CompositionOutput(id: brief.id, pages: pages, spreadGroups: spreadGroups, rhythmScore: rhythmScore, densityScore: densityScore, estimatedVisitMinutes: visitMinutes, flags: flags, visitorText: visitorText)
    }
}
