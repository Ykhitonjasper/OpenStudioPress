import Observation
import SwiftUI

struct LibraryGridScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var viewModel: ViewModel

    init() {
        self.init(dependencies: .app())
    }

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: ViewModel(repository: dependencies.artifacts))
    }

    var body: some View {
        ZStack {
            AppBackground()

            if viewModel.artifacts.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header

                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 160), spacing: 14)],
                            spacing: 14
                        ) {
                            ForEach(viewModel.artifacts) { artifact in
                                artifactCard(for: artifact)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(AppTheme.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reload()
        }
    }

    private var header: some View {
        StudioSectionHeader(
            eyebrow: "Collection",
            title: "Your library",
            subtitle: "\(viewModel.artifacts.count) completed booklets ready to revisit or refine."
        )
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Your library is ready", systemImage: "books.vertical")
        } description: {
            Text("Start a new booklet and it will appear here when it is complete.")
        } actions: {
            Button("Create a Booklet", action: startBlank)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .accessibilityHint("Opens Create with a fresh blank booklet.")
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding()
    }

    private func artifactCard(for artifact: Artifact) -> some View {
        Button {
            store.route = .artifactDetail(artifact.id)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accent)
                        .accessibilityHidden(true)

                    Spacer()

                    Text("\(artifact.blockIDs.count) blocks")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.textMono)
                }

                Spacer(minLength: 12)

                Text(artifact.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text(artifact.size.label)
                    Text("\(artifact.density.label) · \(artifact.foldRhythm.label)")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 190, alignment: .leading)
            .studioPanel(emphasized: true)
        }
        .buttonStyle(StudioPressStyle())
        .accessibilityLabel(
            "\(artifact.title), \(artifact.size.label), \(artifact.density.label), \(artifact.foldRhythm.label), \(artifact.blockIDs.count) blocks"
        )
        .accessibilityHint("Opens the booklet details and block outline.")
    }

    private func startBlank() {
        store.brief = CreateBrief(
            id: "draft-current",
            title: "Untitled Booklet",
            size: .halfLetter,
            templateID: nil,
            density: .balanced,
            foldRhythm: .paired
        )
        store.draftBlocks = []
        store.composition = nil
        store.route = nil
        store.selectedTab = .create
    }

    @MainActor
    @Observable
    final class ViewModel {
        private let repository: any ArtifactRepository
        var artifacts: [Artifact] = []

        init(repository: any ArtifactRepository) {
            self.repository = repository
            reload()
        }

        func reload() {
            artifacts = repository.artifacts().sorted { $0.createdAt > $1.createdAt }
        }
    }
}

#Preview {
    LibraryGridScreen(dependencies: .preview())
        .environment(AppDependencies.preview().store)
}
