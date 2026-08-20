import SwiftUI

struct InkLayoutControlsScreen: View {
    @Environment(StudioAppStore.self) private var store

    private let compositionEngine: any CompositionEngine

    init(compositionEngine: any CompositionEngine = PureCompositionEngine()) {
        self.compositionEngine = compositionEngine
    }

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            ZStack {
                AppBackground()

                List {
                    Section {
                        Text("Adjust the reading pace while keeping every editorial block unchanged.")
                            .foregroundStyle(AppTheme.textSecondary)
                            .accessibilityLabel("Layout changes preserve every editorial block.")
                    }
                    .listRowBackground(AppTheme.bgElevated)

                    Section {
                        Picker("Reading Density", selection: $store.brief.density) {
                            ForEach(ReadingDensity.allCases, id: \.self) { density in
                                Text(density.label).tag(density)
                            }
                        }
                        .pickerStyle(.inline)
                        .accessibilityHint("Reallocates the existing editorial blocks across pages.")
                    } header: {
                        Text("Reading Density")
                    } footer: {
                        Text("Changes update page allocation and density score immediately.")
                    }

                    Section {
                        Picker("Fold Rhythm", selection: $store.brief.foldRhythm) {
                            ForEach(FoldRhythm.allCases, id: \.self) { rhythm in
                                Text(rhythm.label).tag(rhythm)
                            }
                        }
                        .pickerStyle(.inline)
                        .accessibilityHint("Rebuilds the visible page groupings without changing editorial blocks.")
                    } header: {
                        Text("Fold Rhythm")
                    } footer: {
                        Text("Changes update the spread grouping and rhythm score immediately.")
                    }

                    Section {
                        if let composition = store.composition {
                            compositionSummary(composition)
                        }
                    } header: {
                        Text("Recomposed Layout")
                    }
                    .listRowBackground(AppTheme.bgElevated)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(AppTheme.displayName)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        synchronizeComposition()
                        store.route = .preview(store.brief.id)
                    } label: {
                        Label("Preview Booklet", systemImage: "book.pages")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .accessibilityHint("Opens the recomposed booklet preview.")
                }
            }
        }
        .onAppear(perform: synchronizeComposition)
        .onChange(of: store.brief.density) { _, _ in
            synchronizeComposition()
        }
        .onChange(of: store.brief.foldRhythm) { _, _ in
            synchronizeComposition()
        }
    }

    private func compositionSummary(_ composition: CompositionOutput) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                metric("Pages", value: "\(composition.pages.count)")
                metric("Density", value: composition.densityScore.formatted(.number.precision(.fractionLength(0))))
                metric("Rhythm", value: composition.rhythmScore.formatted(.percent.precision(.fractionLength(0))))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Spread Grouping")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                ForEach(Array(composition.spreadGroups.enumerated()), id: \.offset) { index, group in
                    Text(spreadLabel(index: index, pageIDs: group))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .accessibilityLabel(spreadLabel(index: index, pageIDs: group))
                }
            }
        }
        .padding(.vertical, 4)
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

    private func spreadLabel(index: Int, pageIDs: [String]) -> String {
        let pages = pageIDs.map { pageNumber(for: $0) }.joined(separator: " + ")
        return "Group \(index + 1): \(pages)"
    }

    private func pageNumber(for pageID: String) -> String {
        pageID.replacingOccurrences(of: "page-", with: "Page ")
    }

    private func synchronizeComposition() {
        store.composition = compositionEngine.compose(brief: store.brief, blocks: store.draftBlocks)
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

    return InkLayoutControlsScreen(compositionEngine: dependencies.compositionEngine)
        .environment(dependencies.store)
}
