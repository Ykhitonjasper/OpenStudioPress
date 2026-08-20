import Observation
import SwiftUI

@MainActor
struct BlockShelfScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var viewModel: ViewModel

    init() {
        self.init(dependencies: .app())
    }

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: ViewModel(blockCatalog: dependencies.blockCatalog))
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shape the visit")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Choose editorial blocks for \(store.brief.title). You can arrange their order next.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .accessibilityElement(children: .combine)

                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.descriptors) { descriptor in
                            blockCard(for: descriptor)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 88)
            }
            .safeAreaInset(edge: .bottom) {
                arrangerButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppTheme.bgBase)
            }
        }
        .navigationTitle(AppTheme.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: viewModel.additionSequence) { previous, current in
            current > previous
        }
    }

    private var arrangerButton: some View {
        Button {
            store.route = .arranger(store.brief)
        } label: {
            HStack {
                Text("Arrange \(store.draftBlocks.count) Blocks")
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(AppTheme.bgBase)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(AppTheme.accent, in: Capsule())
        }
        .accessibilityLabel("Arrange \(store.draftBlocks.count) selected blocks")
        .accessibilityHint("Opens the arranger with the current block sequence.")
    }

    private func blockCard(for descriptor: BlockKindDescriptor) -> some View {
        let source = viewModel.sourceBlock(for: descriptor.kind)
        let count = store.draftBlocks.filter { $0.kind == descriptor.kind }.count

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: symbol(for: descriptor.kind))
                    .font(.title3)
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 30)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(descriptor.label)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(descriptor.guidance)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                if count > 0 {
                    Text("\(count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.bgBase)
                        .padding(7)
                        .background(AppTheme.accent, in: Circle())
                        .accessibilityLabel("\(count) added")
                }
            }

            if let source {
                Text(source.heading)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
            }

            Button {
                viewModel.add(descriptor, to: &store.draftBlocks)
            } label: {
                Label("Add \(descriptor.label)", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(source == nil)
            .accessibilityLabel(source.map { "Add \(descriptor.label): \($0.heading)" } ?? "Add \(descriptor.label)")
            .accessibilityValue(count == 0 ? "Not added" : "\(count) added")
            .accessibilityHint(source.map { "Adds \($0.heading) to the draft." } ?? "Adds a seeded \(descriptor.label.lowercased()) to the draft.")
        }
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private func symbol(for kind: BlockKind) -> String {
        switch kind {
        case .coverMark: "rectangle.on.rectangle.angled"
        case .artistNote: "pencil.line"
        case .exhibitStop: "mappin.and.ellipse"
        case .processWindow: "rectangle.3.group"
        case .materialCallout: "circle.hexagongrid"
        case .lookingPrompt: "eye"
        case .studioEtiquette: "figure.walk"
        case .takeHomeNote: "hand.draw"
        }
    }

    @MainActor
    @Observable
    final class ViewModel {
        let descriptors: [BlockKindDescriptor]
        private let blocks: [Block]
        var additionSequence = 0

        init(blockCatalog: any BlockCatalog) {
            descriptors = blockCatalog.blockKinds().sorted { $0.kind.rank < $1.kind.rank }
            blocks = blockCatalog.blocks()
        }

        func sourceBlock(for kind: BlockKind) -> Block? {
            blocks.first { $0.kind == kind }
        }

        func add(_ descriptor: BlockKindDescriptor, to draftBlocks: inout [Block]) {
            guard let source = sourceBlock(for: descriptor.kind) else { return }

            let identifierPrefix = "draft-\(descriptor.kind.code)-"
            let copyIndex = (draftBlocks.compactMap { block in
                guard block.id.hasPrefix(identifierPrefix) else { return nil }
                return Int(block.id.dropFirst(identifierPrefix.count))
            }.max() ?? 0) + 1
            draftBlocks.append(
                Block(
                    id: "draft-\(descriptor.kind.code)-\(copyIndex)",
                    kind: source.kind,
                    heading: source.heading,
                    body: source.body,
                    order: draftBlocks.count,
                    emphasis: source.emphasis
                )
            )
            additionSequence += 1
        }
    }
}

#Preview {
    NavigationStack {
        BlockShelfScreen(dependencies: .preview())
    }
    .environment(AppDependencies.preview().store)
}
