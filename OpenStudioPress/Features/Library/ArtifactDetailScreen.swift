import Observation
import SwiftUI

@MainActor
struct ArtifactDetailScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var viewModel: ViewModel

    init(artifactID: String) {
        self.init(artifactID: artifactID, dependencies: .app())
    }

    init(artifactID: String, dependencies: AppDependencies) {
        _viewModel = State(
            initialValue: ViewModel(
                artifactID: artifactID,
                artifacts: dependencies.artifacts,
                blockCatalog: dependencies.blockCatalog
            )
        )
    }

    var body: some View {
        ZStack {
            AppBackground()

            if let artifact = viewModel.artifact {
                if viewModel.blocks.isEmpty {
                    emptyBlocksState(for: artifact)
                } else {
                    detailContent(for: artifact)
                }
            } else {
                unavailableState
            }
        }
        .navigationTitle(AppTheme.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailContent(for artifact: Artifact) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header(for: artifact)
                metadata(for: artifact)
                blockOutline
            }
            .padding(20)
            .padding(.bottom, 92)
        }
        .safeAreaInset(edge: .bottom) {
            actionBar(for: artifact)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppTheme.bgBase)
        }
    }

    private func header(for artifact: Artifact) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(artifact.title)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.textPrimary)

            Text("\(viewModel.blocks.count) blocks arranged for a \(artifact.size.label.lowercased()) booklet.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(artifact.title), \(viewModel.blocks.count) blocks")
    }

    private func metadata(for artifact: Artifact) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Booklet details")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                GridRow {
                    metadataLabel("Size")
                    metadataValue(artifact.size.label)
                }
                GridRow {
                    metadataLabel("Reading density")
                    metadataValue(artifact.density.label)
                }
                GridRow {
                    metadataLabel("Fold rhythm")
                    metadataValue(artifact.foldRhythm.label)
                }
                GridRow {
                    metadataLabel("Created")
                    metadataValue(artifact.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
        }
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Booklet details. Size: \(artifact.size.label). Reading density: \(artifact.density.label). Fold rhythm: \(artifact.foldRhythm.label). Created \(artifact.createdAt.formatted(date: .abbreviated, time: .shortened))."
        )
    }

    private func metadataLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(AppTheme.textSecondary)
    }

    private func metadataValue(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.textPrimary)
    }

    private var blockOutline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Block outline")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text("Saved order")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.blocks.enumerated()), id: \.element.id) { index, block in
                    blockRow(block, position: index + 1)

                    if index < viewModel.blocks.count - 1 {
                        Divider()
                            .overlay(AppTheme.hairline)
                            .padding(.leading, 44)
                    }
                }
            }
            .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Block outline in saved order")
    }

    private func blockRow(_ block: Block, position: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(position.formatted())
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.textMono)
                .frame(width: 20, alignment: .leading)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(block.kind.label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(block.heading)
                    .font(block.emphasis ? .headline.weight(.bold) : .headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(block.body)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Block \(position) of \(viewModel.blocks.count). \(block.kind.label): \(block.heading). \(block.body)"
        )
    }

    private func actionBar(for artifact: Artifact) -> some View {
        HStack(spacing: 12) {
            Button {
                store.route = .duplicateSetup(artifact.id)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
            .accessibilityHint("Opens a prefilled duplicate for \(artifact.title).")

            Button {
                store.route = .export(artifact.id)
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .accessibilityHint("Opens document formats for \(artifact.title).")
        }
    }

    private func emptyBlocksState(for artifact: Artifact) -> some View {
        ContentUnavailableView {
            Label("No blocks in this booklet", systemImage: "text.badge.xmark")
        } description: {
            Text("\(artifact.title) has no saved blocks to outline yet.")
        } actions: {
            Button("Return to Library", action: returnToLibrary)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .accessibilityHint("Returns to your saved booklets.")
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding()
    }

    private var unavailableState: some View {
        ContentUnavailableView {
            Label("Booklet unavailable", systemImage: "book.closed")
        } description: {
            Text("This booklet is no longer available in your library.")
        } actions: {
            Button("Return to Library", action: returnToLibrary)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .accessibilityHint("Returns to your saved booklets.")
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding()
    }

    private func returnToLibrary() {
        store.route = nil
        store.selectedTab = .library
    }

    @MainActor
    @Observable
    final class ViewModel {
        private(set) var artifact: Artifact?
        private(set) var blocks: [Block]

        init(
            artifactID: String,
            artifacts: any ArtifactRepository,
            blockCatalog: any BlockCatalog
        ) {
            let selectedArtifact = artifacts.artifact(id: artifactID)
            let snapshots = artifacts.snapshots(artifactID: artifactID)
            let orderedBlocks: [Block]

            if snapshots.isEmpty {
                let blocksByID = Dictionary(
                    uniqueKeysWithValues: blockCatalog.blocks().map { ($0.id, $0) }
                )
                orderedBlocks = selectedArtifact?.blockIDs.compactMap { blocksByID[$0] } ?? []
            } else {
                orderedBlocks = snapshots.map { $0.makeBlock() }
            }

            artifact = selectedArtifact
            blocks = orderedBlocks
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    ArtifactDetailScreen(artifactID: "art-001", dependencies: dependencies)
        .environment(dependencies.store)
}
