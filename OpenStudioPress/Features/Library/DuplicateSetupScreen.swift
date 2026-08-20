import Observation
import SwiftUI

struct DuplicateSetupScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StudioAppStore.self) private var store
    @State private var viewModel: ViewModel
    @FocusState private var isTitleFocused: Bool

    @MainActor
    init(artifactID: String) {
        self.init(artifactID: artifactID, dependencies: .app())
    }

    @MainActor
    init(artifactID: String, dependencies: AppDependencies) {
        _viewModel = State(
            initialValue: ViewModel(
                artifactID: artifactID,
                artifactRepository: dependencies.artifacts,
                blockCatalog: dependencies.blockCatalog
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        titleField
                        if viewModel.hasSource {
                            sourceSummary
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(AppTheme.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                        .accessibilityHint("Closes duplication setup without changing the source booklet.")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Copy", action: confirm)
                        .tint(AppTheme.accent)
                        .disabled(!viewModel.isTitleValid)
                        .accessibilityHint("Creates a local draft and opens it in the arranger.")
                }
            }
        }
        .onAppear {
            viewModel.loadDraftSource(from: store)
            isTitleFocused = true
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duplicate booklet")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.textPrimary)

            Text("Create a separate working draft while keeping the original booklet unchanged.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New title")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            TextField("Booklet title", text: $viewModel.title)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($isTitleFocused)
                .padding(14)
                .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(viewModel.isTitleValid ? AppTheme.hairline : AppTheme.danger, lineWidth: 1)
                }
                .accessibilityLabel("Title for duplicated booklet")
                .accessibilityHint("Enter a title for the new local draft.")

            if !viewModel.isTitleValid {
                Text("Enter a title to create the duplicate.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.danger)
                    .accessibilityLabel("Title is required")
            }
        }
    }

    private var sourceSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Copied from \(viewModel.sourceTitle)", systemImage: "doc.on.doc")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.sourceSize.label) · \(viewModel.sourceDensity.label)")
                Text("\(viewModel.sourceFoldRhythm.label) · \(viewModel.sourceBlockCount) blocks")
            }
            .font(.subheadline)
            .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Source booklet \(viewModel.sourceTitle), \(viewModel.sourceSize.label), \(viewModel.sourceDensity.label), \(viewModel.sourceFoldRhythm.label), \(viewModel.sourceBlockCount) blocks"
        )
    }

    private func confirm() {
        guard viewModel.isTitleValid, let brief = viewModel.makeBrief() else { return }

        store.brief = brief
        store.draftBlocks = viewModel.makeDraftBlocks()
        store.composition = nil
        store.route = .arranger(brief.id)
        dismiss()
    }

    private func cancel() {
        store.route = nil
        dismiss()
    }

    @MainActor
    @Observable
    final class ViewModel {
        let source: Artifact?
        private let sourceSnapshots: [ArtifactBlockSnapshot]
        private let copyID: String
        private var draftSource: CreateBrief?
        private var draftSourceBlocks: [Block] = []
        var title: String

        init(artifactID: String, artifactRepository: any ArtifactRepository, blockCatalog: any BlockCatalog) {
            let resolvedSource = artifactRepository.artifact(id: artifactID)
            let copyPrefix = "\(artifactID)-copy"
            let existingIDs = Set(artifactRepository.artifacts().map(\.id))
            let copyNumber = (1...).first { !existingIDs.contains("\(copyPrefix)-\($0)") } ?? existingIDs.count + 1
            source = resolvedSource
            sourceSnapshots = artifactRepository.snapshots(artifactID: artifactID)
            copyID = "\(copyPrefix)-\(copyNumber)"
            title = resolvedSource.map { "\($0.title) Copy" } ?? ""
        }

        var hasSource: Bool {
            source != nil || draftSource != nil
        }

        var sourceTitle: String {
            source?.title ?? draftSource?.title ?? ""
        }

        var sourceSize: BookletSize {
            source?.size ?? draftSource?.size ?? .halfLetter
        }

        var sourceDensity: ReadingDensity {
            source?.density ?? draftSource?.density ?? .balanced
        }

        var sourceFoldRhythm: FoldRhythm {
            source?.foldRhythm ?? draftSource?.foldRhythm ?? .paired
        }

        var sourceBlockCount: Int {
            source == nil ? draftSourceBlocks.count : sourceSnapshots.count
        }

        var isTitleValid: Bool {
            hasSource && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        func loadDraftSource(from store: StudioAppStore) {
            guard source == nil, draftSource == nil else { return }
            draftSource = store.brief
            draftSourceBlocks = store.draftBlocks
            title = "\(store.brief.title) Copy"
        }

        func makeBrief() -> CreateBrief? {
            guard hasSource else { return nil }
            return CreateBrief(
                id: copyID,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                size: sourceSize,
                templateID: nil,
                density: sourceDensity,
                foldRhythm: sourceFoldRhythm
            )
        }

        func makeDraftBlocks() -> [Block] {
            if source != nil {
                return sourceSnapshots.map { snapshot in
                    Block(
                        id: "\(copyID)-\(snapshot.id)",
                        kind: snapshot.kind,
                        heading: snapshot.heading,
                        body: snapshot.body,
                        order: snapshot.order,
                        emphasis: snapshot.emphasis
                    )
                }
            }

            return draftSourceBlocks.map { block in
                return Block(
                    id: "\(copyID)-\(block.id)",
                    kind: block.kind,
                    heading: block.heading,
                    body: block.body,
                    order: block.order,
                    emphasis: block.emphasis
                )
            }
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    return DuplicateSetupScreen(artifactID: "art-001", dependencies: dependencies)
        .environment(dependencies.store)
}
