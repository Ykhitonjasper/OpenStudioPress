import SwiftUI

struct StopArrangerScreen: View {
    @Environment(StudioAppStore.self) private var store

    private let compositionEngine: any CompositionEngine
    @State private var blocks: [Block] = []
    @State private var hasLoadedDraft = false

    init(compositionEngine: any CompositionEngine = PureCompositionEngine()) {
        self.compositionEngine = compositionEngine
    }

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            ZStack {
                AppBackground()

                if blocks.isEmpty {
                    ContentUnavailableView {
                        Label("Start Your Outline", systemImage: "rectangle.stack.badge.plus")
                    } description: {
                        Text("Choose editorial blocks to shape the visitor route for \(store.brief.title).")
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
                } else {
                    List {
                        Section {
                            compositionSummary
                        }
                        .listRowBackground(AppTheme.bgElevated)

                        Section {
                            ForEach(blocks) { block in
                                blockEditor(block)
                            }
                            .onMove(perform: moveBlocks)
                            .onDelete(perform: removeBlocks)
                        } header: {
                            Text("Editorial Order")
                        } footer: {
                            Text("Drag blocks to change the booklet sequence. Every change updates the composition.")
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(AppTheme.displayName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .accessibilityLabel("Reorder blocks")
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        openPreview()
                    } label: {
                        Label("Preview Booklet", systemImage: "book.pages")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .disabled(blocks.isEmpty)
                    .accessibilityHint("Recomputes the booklet and opens its preview.")
                }
            }
        }
        .onAppear(perform: loadDraft)
    }

    @ViewBuilder
    private var compositionSummary: some View {
        if let composition = store.composition {
            VStack(alignment: .leading, spacing: 10) {
                Label("Composition updated", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)

                HStack(spacing: 16) {
                    metric("Pages", value: "\(composition.pages.count)")
                    metric("Rhythm", value: composition.rhythmScore.formatted(.percent.precision(.fractionLength(0))))
                    metric("Visit", value: "\(composition.estimatedVisitMinutes) min")
                }

                if composition.flags.isEmpty {
                    Text("The current sequence has no structural flags.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                } else {
                    Text(composition.flags.map(\.label).joined(separator: " • "))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .accessibilityLabel("Composition notes: \(composition.flags.map(\.label).joined(separator: ", "))")
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func blockEditor(_ block: Block) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(block.order + 1). \(block.kind.label)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)

                Spacer()

                Button {
                    duplicate(block)
                } label: {
                    Image(systemName: "plus.square.on.square")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Duplicate \(block.heading)")
                .accessibilityHint("Inserts a copy after this block.")

                Button(role: .destructive) {
                    remove(block)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Remove \(block.heading)")
            }

            TextField(
                "Heading",
                text: Binding(
                    get: { block.heading },
                    set: {
                        block.heading = $0
                        synchronizeComposition()
                    }
                )
            )
            .font(.headline)
            .accessibilityLabel("Heading for \(block.kind.label)")

            TextField(
                "Body",
                text: Binding(
                    get: { block.body },
                    set: {
                        block.body = $0
                        synchronizeComposition()
                    }
                ),
                axis: .vertical
            )
            .lineLimit(2...5)
            .foregroundStyle(AppTheme.textSecondary)
            .accessibilityLabel("Body for \(block.heading)")

            Toggle(
                "Feature this block",
                isOn: Binding(
                    get: { block.emphasis },
                    set: {
                        block.emphasis = $0
                        synchronizeComposition()
                    }
                )
            )
            .font(.subheadline)
            .tint(AppTheme.accent)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }

    private func metric(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func loadDraft() {
        guard !hasLoadedDraft else { return }
        hasLoadedDraft = true
        blocks = store.draftBlocks.sorted { $0.order < $1.order }
        normalizeOrders()
        synchronizeComposition()
    }

    private func moveBlocks(from source: IndexSet, to destination: Int) {
        blocks.move(fromOffsets: source, toOffset: destination)
        normalizeOrders()
        synchronizeComposition()
    }

    private func duplicate(_ block: Block) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }

        let copy = Block(
            id: duplicateID(for: block),
            kind: block.kind,
            heading: "\(block.heading) Copy",
            body: block.body,
            order: index + 1,
            emphasis: block.emphasis
        )
        blocks.insert(copy, at: index + 1)
        normalizeOrders()
        synchronizeComposition()
    }

    private func remove(_ block: Block) {
        guard let index = blocks.firstIndex(where: { $0.id == block.id }) else { return }
        blocks.remove(at: index)
        normalizeOrders()
        synchronizeComposition()
    }

    private func removeBlocks(at offsets: IndexSet) {
        blocks.remove(atOffsets: offsets)
        normalizeOrders()
        synchronizeComposition()
    }

    private func duplicateID(for block: Block) -> String {
        let prefix = "\(block.id)-copy-"
        let existingIDs = Set(blocks.map(\.id))
        let nextNumber = (1...)
            .first { !existingIDs.contains("\(prefix)\($0)") } ?? blocks.count + 1
        return "\(prefix)\(nextNumber)"
    }

    private func normalizeOrders() {
        for (index, block) in blocks.enumerated() {
            block.order = index
        }
    }

    private func synchronizeComposition() {
        store.draftBlocks = blocks
        store.composition = compositionEngine.compose(brief: store.brief, blocks: blocks)
    }

    private func openPreview() {
        synchronizeComposition()
        store.route = .preview(store.brief.id)
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    dependencies.store.brief = CreateBrief(
        id: "preview-brief",
        title: "Clay & Ash",
        size: .halfLetter,
        templateID: "tpl-001",
        density: .balanced,
        foldRhythm: .paired
    )
    dependencies.store.draftBlocks = Array(StudioSeedData.blocks().prefix(5))

    return StopArrangerScreen(compositionEngine: dependencies.compositionEngine)
        .environment(dependencies.store)
}
