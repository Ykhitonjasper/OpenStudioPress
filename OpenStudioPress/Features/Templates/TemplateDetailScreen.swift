import Observation
import SwiftUI

@MainActor
struct TemplateDetailScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var viewModel: ViewModel

    init(templateID: String) {
        self.init(templateID: templateID, dependencies: .app())
    }

    init(templateID: String, dependencies: AppDependencies) {
        _viewModel = State(
            initialValue: ViewModel(
                templateID: templateID,
                templates: dependencies.templates,
                blockCatalog: dependencies.blockCatalog
            )
        )
    }

    var body: some View {
        ZStack {
            AppBackground()

            if let template = viewModel.template {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header(for: template)
                        sequencePreview
                        if let guidance = viewModel.selectedGuidance {
                            guidanceCard(guidance)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 92)
                }
                .safeAreaInset(edge: .bottom) {
                    useTemplateButton
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(AppTheme.bgBase)
                }
            } else {
                missingTemplateState
            }
        }
        .navigationTitle(AppTheme.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: viewModel.inspectionSequence)
        .sensoryFeedback(.success, trigger: viewModel.useSequence) { previous, current in
            current > previous
        }
    }

    private func header(for template: Template) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(template.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(template.summary)
                .font(.body)
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: 8) {
                Label(template.size.label, systemImage: "book.closed")
                Label(template.density.label, systemImage: "text.alignleft")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.textMono)
        }
        .accessibilityElement(children: .combine)
    }

    private var sequencePreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Template sequence")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Text("\(viewModel.blocks.count) blocks")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(Array(viewModel.blocks.enumerated()), id: \.element.id) { index, block in
                Button {
                    viewModel.inspect(block)
                } label: {
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.bgBase)
                            .frame(width: 26, height: 26)
                            .background(AppTheme.accent, in: Circle())
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(block.kind.label)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.accent)

                            Text(block.heading)
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            Text(block.body)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: viewModel.selectedBlockID == block.id ? "info.circle.fill" : "info.circle")
                            .foregroundStyle(viewModel.selectedBlockID == block.id ? AppTheme.accent : AppTheme.textSecondary)
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(viewModel.selectedBlockID == block.id ? AppTheme.accent : AppTheme.hairline, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(index + 1). \(block.kind.label): \(block.heading)")
                .accessibilityHint("Shows guidance for this block family.")
                .accessibilityAddTraits(viewModel.selectedBlockID == block.id ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func guidanceCard(_ guidance: BlockKindDescriptor) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Block guidance", systemImage: "lightbulb")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text("\(guidance.label): \(guidance.guidance)")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var useTemplateButton: some View {
        Button {
            guard let draft = viewModel.makeDraft() else { return }
            store.brief = draft.brief
            store.draftBlocks = draft.blocks
            store.composition = nil
            store.selectedTab = .create
            store.route = .arranger(draft.brief)
            viewModel.useSequence += 1
        } label: {
            Label("Use in Create", systemImage: "square.and.pencil")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.accent)
        .disabled(viewModel.blocks.isEmpty)
        .accessibilityHint("Copies this template into an editable draft and opens the arranger.")
    }

    private var missingTemplateState: some View {
        ContentUnavailableView {
            Label("Template Unavailable", systemImage: "rectangle.stack.badge.xmark")
        } description: {
            Text("This starter could not be found. Browse the template collection to choose another one.")
        } actions: {
            Button("Browse Templates") {
                store.selectedTab = .templates
                store.route = nil
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .accessibilityHint("Returns to the Templates tab.")
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding()
    }

    @MainActor
    @Observable
    final class ViewModel {
        let template: Template?
        let blocks: [Block]
        private let descriptors: [BlockKindDescriptor]

        var selectedBlockID: String?
        var inspectionSequence = 0
        var useSequence = 0

        init(templateID: String, templates: any TemplateRepository, blockCatalog: any BlockCatalog) {
            let template = templates.template(id: templateID)
            self.template = template
            self.blocks = template?.blockIDs.compactMap { blockCatalog.block(id: $0) } ?? []
            self.descriptors = blockCatalog.blockKinds()
        }

        var selectedGuidance: BlockKindDescriptor? {
            guard let selectedBlockID,
                  let selectedBlock = blocks.first(where: { $0.id == selectedBlockID }) else {
                return nil
            }
            return descriptors.first { $0.kind == selectedBlock.kind }
        }

        func inspect(_ block: Block) {
            selectedBlockID = block.id
            inspectionSequence += 1
        }

        func makeDraft() -> DraftBooklet? {
            guard let template else { return nil }
            let brief = CreateBrief(
                id: "draft-current",
                title: template.title,
                size: template.size,
                templateID: template.id,
                density: template.density,
                foldRhythm: .paired
            )
            let copiedBlocks = blocks.enumerated().map { index, block in
                Block(
                    id: "draft-\(template.id)-\(block.id)",
                    kind: block.kind,
                    heading: block.heading,
                    body: block.body,
                    order: index,
                    emphasis: block.emphasis
                )
            }
            return DraftBooklet(id: brief.id, brief: brief, blocks: copiedBlocks)
        }
    }
}

#Preview {
    let dependencies = AppDependencies.preview()

    return NavigationStack {
        TemplateDetailScreen(templateID: "tpl-002", dependencies: dependencies)
    }
    .environment(dependencies.store)
}
