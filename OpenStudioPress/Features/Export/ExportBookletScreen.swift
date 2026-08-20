import Foundation
import Observation
import SwiftUI

@MainActor
struct ExportBookletScreen: View {
    @Environment(\.dismiss) private var dismiss
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
                compositionEngine: dependencies.compositionEngine,
                exportDocuments: dependencies.exportDocuments
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if let composition = viewModel.composition {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            header(for: composition)
                            compositionSummary(for: composition)
                            formatOptions

                            if let preparedDocument = viewModel.preparedDocument {
                                preparedDocumentCard(preparedDocument)
                            }
                        }
                        .padding(20)
                    }
                } else {
                    unavailableState
                }
            }
            .navigationTitle(AppTheme.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: dismiss.callAsFunction)
                        .accessibilityHint("Closes export options without sharing a document.")
                }
            }
        }
        .onAppear {
            viewModel.load(from: store)
        }
    }

    private func header(for composition: CompositionOutput) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Export booklet")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.textPrimary)

            Text("Prepare a visitor guide from the current \(composition.pages.count)-page composition, then choose where to share it.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func compositionSummary(for composition: CompositionOutput) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Source composition")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 24) {
                metric("Pages", value: composition.pages.count.formatted())
                metric("Visit", value: "\(composition.estimatedVisitMinutes) min")
                metric("Words", value: composition.visitorText.split(whereSeparator: \.isWhitespace).count.formatted())
            }
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
            "Source composition. \(composition.pages.count) pages. Estimated visit \(composition.estimatedVisitMinutes) minutes. \(composition.visitorText.split(whereSeparator: \.isWhitespace).count) words."
        )
    }

    private var formatOptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Document format")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            exportOption(
                format: .plainText,
                title: "Plain Text",
                detail: "A readable text guide for notes, email, and simple printing.",
                systemImage: "doc.text"
            )

            exportOption(
                format: .printPDF,
                title: "Print-ready PDF",
                detail: "A paginated visitor guide for printing or sending as a finished document.",
                systemImage: "doc.richtext"
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Document format options")
    }

    private func exportOption(
        format: ExportFormat,
        title: String,
        detail: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            Button {
                viewModel.prepare(format)
            } label: {
                Label("Prepare \(title)", systemImage: "arrow.down.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.accent)
            .accessibilityHint("Builds a local \(title.lowercased()) document. It will not be shared until you choose Share.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
    }

    private func preparedDocumentCard(_ document: PreparedDocument) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("\(document.document.format.label) ready", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.accent)

            Text(document.document.filename)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            ShareLink(item: document.fileURL) {
                Label("Share document", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .accessibilityLabel("Share \(document.document.filename)")
            .accessibilityHint("Opens the system share sheet for this local document.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(document.document.format.label) document \(document.document.filename) is ready.")
    }

    private var unavailableState: some View {
        ContentUnavailableView {
            Label("Booklet unavailable", systemImage: "book.closed")
        } description: {
            Text("This booklet no longer has composition content available for export.")
        } actions: {
            Button("Done", action: dismiss.callAsFunction)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .accessibilityHint("Closes export options.")
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding()
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

    @MainActor
    @Observable
    final class ViewModel {
        private let artifactID: String
        private let artifact: Artifact?
        private let artifacts: any ArtifactRepository
        private let compositionEngine: any CompositionEngine
        private let exportDocuments: any ExportDocumentService

        var composition: CompositionOutput?
        var preparedDocument: PreparedDocument?

        init(
            artifactID: String,
            artifacts: any ArtifactRepository,
            compositionEngine: any CompositionEngine,
            exportDocuments: any ExportDocumentService
        ) {
            self.artifactID = artifactID
            artifact = artifacts.artifact(id: artifactID)
            self.artifacts = artifacts
            self.compositionEngine = compositionEngine
            self.exportDocuments = exportDocuments
        }

        func load(from store: StudioAppStore) {
            guard composition == nil else { return }

            if let artifact {
                let blocks = artifacts.snapshots(artifactID: artifact.id)
                    .sorted { $0.order < $1.order }
                    .map { $0.makeBlock() }
                guard !blocks.isEmpty else { return }

                let brief = CreateBrief(
                    id: artifact.id,
                    title: artifact.title,
                    size: artifact.size,
                    templateID: nil,
                    density: artifact.density,
                    foldRhythm: artifact.foldRhythm
                )
                composition = compositionEngine.compose(brief: brief, blocks: blocks)
                return
            }

            guard artifactID == store.brief.id, !store.draftBlocks.isEmpty else { return }
            composition = store.composition ?? compositionEngine.compose(brief: store.brief, blocks: store.draftBlocks)
        }

        func prepare(_ format: ExportFormat) {
            guard let composition else { return }

            let document = switch format {
            case .plainText:
                exportDocuments.plainText(output: composition)
            case .printPDF:
                exportDocuments.printPDF(output: composition)
            }

            preparedDocument = Self.materialize(document)
        }

        private static func materialize(_ document: ExportDocument) -> PreparedDocument? {
            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent("OpenStudioPress-Exports", isDirectory: true)
                .appendingPathComponent(document.id, isDirectory: true)
            let fileURL = directory.appendingPathComponent(document.filename, isDirectory: false)

            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                try Data(document.bytes).write(to: fileURL, options: .atomic)
                return PreparedDocument(document: document, fileURL: fileURL)
            } catch {
                return nil
            }
        }
    }

    struct PreparedDocument: Identifiable {
        let document: ExportDocument
        let fileURL: URL

        var id: String {
            document.id
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    return ExportBookletScreen(artifactID: "art-001", dependencies: dependencies)
        .environment(dependencies.store)
}
