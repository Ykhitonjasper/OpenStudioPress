import Observation
import SwiftUI

@MainActor
struct LiveBookletPreviewScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var viewModel: ViewModel

    init() {
        self.init(dependencies: .app())
    }

    init(dependencies: AppDependencies) {
        _viewModel = State(
            initialValue: ViewModel(
                compositionEngine: dependencies.compositionEngine,
                artifacts: dependencies.artifacts
            )
        )
    }

    var body: some View {
        ZStack {
            AppBackground()

            if let composition = viewModel.composition {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header(for: composition)
                        spreadPreview(for: composition)
                        spreadControls(for: composition)
                        compositionSummary(for: composition)
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
                .safeAreaInset(edge: .bottom) {
                    actionBar(for: composition)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(AppTheme.bgBase)
                }
            } else {
                ContentUnavailableView {
                    Label("No Pages to Preview", systemImage: "book.closed")
                } description: {
                    Text("Add editorial blocks to create a booklet preview.")
                } actions: {
                    Button("Choose Blocks") {
                        store.route = .blockShelf(store.brief)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .accessibilityHint("Returns to the block shelf to add editorial blocks.")
                }
                .foregroundStyle(AppTheme.textPrimary)
                .padding()
            }
        }
        .navigationTitle(AppTheme.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load(
                brief: store.brief,
                blocks: store.draftBlocks,
                existingComposition: store.composition
            )
        }
        .sensoryFeedback(.selection, trigger: viewModel.pageSelection)
        .sensoryFeedback(.success, trigger: viewModel.saveSequence) { previous, current in
            current > previous
        }
    }

    private func header(for composition: CompositionOutput) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.brief.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("\(store.brief.size.label) • \(store.brief.density.label) reading")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            if viewModel.didSave {
                Label("Saved to Library", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityLabel("Booklet saved to Library")
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func spreadPreview(for composition: CompositionOutput) -> some View {
        let pages = viewModel.pagesInCurrentSpread

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(spreadLabel(for: composition))
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Text("\(composition.pages.count) pages")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(pages) { page in
                        bookletPage(page)
                    }
                }

                VStack(spacing: 12) {
                    ForEach(pages) { page in
                        bookletPage(page)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Booklet spread \(spreadLabel(for: composition))")
    }

    private func bookletPage(_ page: PageComposition) -> some View {
        let blocks = viewModel.blocks(for: page)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PAGE \(page.index + 1)")
                    .font(.caption2.weight(.bold))
                    .tracking(1)
                    .foregroundStyle(AppTheme.accent)

                Spacer()

                if page.crowded {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(AppTheme.danger)
                        .accessibilityLabel("This page is crowded")
                }
            }

            ForEach(blocks) { block in
                VStack(alignment: .leading, spacing: 4) {
                    Text(block.heading)
                        .font(block.emphasis ? .headline.weight(.bold) : .subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.paperInk)

                    Text(block.body)
                        .font(.caption)
                        .foregroundStyle(AppTheme.paperInk.opacity(0.62))
                        .lineLimit(4)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240, alignment: .topLeading)
        .padding(16)
        .background(AppTheme.paper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.rimStroke, lineWidth: 1)
        }
        .shadow(color: AppTheme.accent.opacity(0.12), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(pageAccessibilityLabel(page, blocks: blocks))
    }

    private func spreadControls(for composition: CompositionOutput) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.previousSpread()
            } label: {
                Label("Previous", systemImage: "chevron.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
            .disabled(!viewModel.canMoveBackward)
            .accessibilityHint("Shows the preceding booklet spread.")

            Button {
                viewModel.nextSpread()
            } label: {
                Label("Next", systemImage: "chevron.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .disabled(!viewModel.canMoveForward)
            .accessibilityHint("Shows the next booklet spread.")
        }
        .accessibilityElement(children: .contain)
        .accessibilityValue(spreadLabel(for: composition))
    }

    private func compositionSummary(for composition: CompositionOutput) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Composition")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 24) {
                metric("Rhythm", value: composition.rhythmScore.formatted(.percent.precision(.fractionLength(0))))
                metric("Visit", value: "\(composition.estimatedVisitMinutes) min")
                metric("Density", value: "\(Int(composition.densityScore))")
            }

            if composition.flags.isEmpty {
                Text("The current composition has no structural flags.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                Button {
                    store.route = .healthPanel(composition.id)
                } label: {
                    Label(
                        "\(composition.flags.count) structural \(composition.flags.count == 1 ? "flag" : "flags")",
                        systemImage: "exclamationmark.triangle"
                    )
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.accent)
                .accessibilityHint("Shows the current composition findings.")
            }
        }
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private func actionBar(for composition: CompositionOutput) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.save(brief: store.brief, blocks: store.draftBlocks)
            } label: {
                Label(viewModel.didSave ? "Saved" : "Save", systemImage: viewModel.didSave ? "checkmark" : "square.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .accessibilityHint("Saves this booklet to the Library.")

            Menu {
                Button {
                    store.route = .duplicateSetup(composition.id)
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }

                Button {
                    store.route = .healthPanel(composition.id)
                } label: {
                    Label("Health", systemImage: "heart.text.square")
                }

                Button {
                    store.route = .export(composition.id)
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            } label: {
                Label("More actions", systemImage: "ellipsis.circle")
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
            .accessibilityHint("Offers duplicate, health, and export actions for this composition.")
        }
    }

    private func metric(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func spreadLabel(for composition: CompositionOutput) -> String {
        let pageNumbers = viewModel.pagesInCurrentSpread.map { String($0.index + 1) }
        return pageNumbers.count == 1
            ? "Page \(pageNumbers[0]) of \(composition.pages.count)"
            : "Pages \(pageNumbers.joined(separator: "–")) of \(composition.pages.count)"
    }

    private func pageAccessibilityLabel(_ page: PageComposition, blocks: [Block]) -> String {
        let content = blocks.map { "\($0.heading). \($0.body)" }.joined(separator: " ")
        let crowding = page.crowded ? "This page is crowded. " : ""
        return "Page \(page.index + 1). \(crowding)\(content)"
    }

    @MainActor
    @Observable
    final class ViewModel {
        private let compositionEngine: any CompositionEngine
        private let artifacts: any ArtifactRepository
        private var draftBlocks: [Block] = []

        var composition: CompositionOutput?
        var pageSelection = 0
        var saveSequence = 0
        var didSave = false

        init(compositionEngine: any CompositionEngine, artifacts: any ArtifactRepository) {
            self.compositionEngine = compositionEngine
            self.artifacts = artifacts
        }

        var pagesInCurrentSpread: [PageComposition] {
            guard let composition else { return [] }
            return Array(composition.pages.dropFirst(pageSelection).prefix(2))
        }

        var canMoveBackward: Bool {
            pageSelection > 0
        }

        var canMoveForward: Bool {
            guard let composition else { return false }
            return pageSelection + 2 < composition.pages.count
        }

        func load(brief: CreateBrief, blocks: [Block], existingComposition: CompositionOutput?) {
            draftBlocks = blocks.sorted { $0.order < $1.order }
            composition = existingComposition?.pages.isEmpty == false
                ? existingComposition
                : (draftBlocks.isEmpty ? nil : compositionEngine.compose(brief: brief, blocks: draftBlocks))
            pageSelection = 0
            didSave = artifacts.artifact(id: brief.id) != nil
        }

        func previousSpread() {
            guard canMoveBackward else { return }
            pageSelection = max(0, pageSelection - 2)
        }

        func nextSpread() {
            guard canMoveForward else { return }
            pageSelection += 2
        }

        func blocks(for page: PageComposition) -> [Block] {
            page.blockIDs.compactMap { identifier in
                draftBlocks.first { $0.id == identifier }
            }
        }

        func save(brief: CreateBrief, blocks: [Block]) {
            let sortedBlocks = blocks.sorted { $0.order < $1.order }
            let blockSnapshots = sortedBlocks.map(ArtifactBlockSnapshot.init)

            artifacts.save(
                artifact: Artifact(
                    id: brief.id,
                    title: brief.title,
                    size: brief.size,
                    density: brief.density,
                    foldRhythm: brief.foldRhythm,
                    blockIDs: sortedBlocks.map(\.id),
                    blockSnapshots: blockSnapshots,
                    createdAt: Date()
                )
            )
            didSave = true
            saveSequence += 1
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    dependencies.store.brief = CreateBrief(
        id: "preview-clay-ash",
        title: "Clay & Ash",
        size: .halfLetter,
        templateID: "tpl-001",
        density: .balanced,
        foldRhythm: .paired
    )
    dependencies.store.draftBlocks = Array(StudioSeedData.blocks().prefix(8))
    dependencies.store.composition = dependencies.compositionEngine.compose(
        brief: dependencies.store.brief,
        blocks: dependencies.store.draftBlocks
    )

    return NavigationStack {
        LiveBookletPreviewScreen(dependencies: dependencies)
    }
    .environment(dependencies.store)
}
