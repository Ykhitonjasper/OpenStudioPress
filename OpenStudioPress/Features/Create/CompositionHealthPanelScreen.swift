import Observation
import SwiftUI

struct CompositionHealthPanelScreen: View {
    @Environment(StudioAppStore.self) private var store

    private let compositionEngine: any CompositionEngine
    @State private var viewModel = ViewModel()

    init() {
        self.init(dependencies: .app())
    }

    init(dependencies: AppDependencies) {
        compositionEngine = dependencies.compositionEngine
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        findings

                        if let selectedFlag = viewModel.selectedFlag {
                            selectedFinding(for: selectedFlag)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Composition Health")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: synchronizeComposition)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review the structure")
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Computed findings for \(store.brief.title) identify where the reading path needs attention.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var findings: some View {
        let output = currentComposition

        if output.flags.isEmpty {
            ContentUnavailableView {
                Label("Structure is clear", systemImage: "checkmark.circle.fill")
            } description: {
                Text("This draft has no computed structural flags.")
            }
            .foregroundStyle(AppTheme.textPrimary)
            .accessibilityLabel("Structure is clear. This draft has no computed structural flags.")
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Computed findings")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                ForEach(output.flags, id: \.self) { flag in
                    Button {
                        viewModel.selectedFlag = flag
                    } label: {
                        findingRow(for: flag, output: output)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel(for: flag, output: output))
                    .accessibilityHint("Shows the affected page and recommended adjustment.")
                    .accessibilityAddTraits(viewModel.selectedFlag == flag ? .isSelected : [])
                }
            }
        }
    }

    private func findingRow(for flag: StructuralFlag, output: CompositionOutput) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol(for: flag))
                .font(.title3)
                .foregroundStyle(flag == .crowdedSpread ? AppTheme.danger : AppTheme.accent)
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(flag.label)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(pageReference(for: flag, output: output))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.accent)

                Text(remedy(for: flag))
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        }
    }

    private func selectedFinding(for flag: StructuralFlag) -> some View {
        let output = currentComposition

        return VStack(alignment: .leading, spacing: 12) {
            Text("Selected finding")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(pageReference(for: flag, output: output))
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.accent)

            Text(remedy(for: flag))
                .font(.body)
                .foregroundStyle(AppTheme.textSecondary)

            if flag == .crowdedSpread {
                Button {
                    resolveCrowding()
                } label: {
                    Label("Use Airy Density", systemImage: "rectangle.compress.vertical")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .accessibilityHint("Reduces the draft density and recomputes this booklet.")
            }
        }
        .padding(16)
        .background(AppTheme.bgElevated, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var currentComposition: CompositionOutput {
        store.composition ?? compositionEngine.compose(brief: store.brief, blocks: store.draftBlocks)
    }

    private func pageReference(for flag: StructuralFlag, output: CompositionOutput) -> String {
        let page: PageComposition?

        switch flag {
        case .crowdedSpread:
            page = output.pages.first(where: \.crowded)
        case .missingOrientation:
            page = output.pages.first
        case .unevenClosingPage:
            page = output.pages.last
        }

        guard let page else {
            return "Affected page is unavailable."
        }

        return "Page \(page.index + 1) · \(page.characterCount) characters"
    }

    private func remedy(for flag: StructuralFlag) -> String {
        switch flag {
        case .crowdedSpread:
            "Reduce the reading density to give this spread more room."
        case .missingOrientation:
            "Place a cover mark at the start to orient visitors."
        case .unevenClosingPage:
            "Move or add a closing block so the final page carries a balanced ending."
        }
    }

    private func symbol(for flag: StructuralFlag) -> String {
        switch flag {
        case .crowdedSpread:
            "rectangle.compress.vertical"
        case .missingOrientation:
            "location.north.line"
        case .unevenClosingPage:
            "rectangle.split.3x1"
        }
    }

    private func accessibilityLabel(for flag: StructuralFlag, output: CompositionOutput) -> String {
        "\(flag.label). \(pageReference(for: flag, output: output)). \(remedy(for: flag))"
    }

    private func synchronizeComposition() {
        store.composition = compositionEngine.compose(brief: store.brief, blocks: store.draftBlocks)
    }

    private func resolveCrowding() {
        store.brief.density = .airy
        synchronizeComposition()
        if !currentComposition.flags.contains(.crowdedSpread) {
            viewModel.selectedFlag = nil
        }
    }

    @MainActor
    @Observable
    final class ViewModel {
        var selectedFlag: StructuralFlag?
    }
}

#Preview {
    let dependencies = AppDependencies.preview()
    let blocks = Array(StudioSeedData.blocks().prefix(8))
    dependencies.store.brief = CreateBrief(
        id: "health-preview",
        title: "Clay & Ash",
        size: .halfLetter,
        templateID: "tpl-001",
        density: .detailed,
        foldRhythm: .paired
    )
    dependencies.store.draftBlocks = blocks
    dependencies.store.composition = dependencies.compositionEngine.compose(
        brief: dependencies.store.brief,
        blocks: blocks
    )

    return CompositionHealthPanelScreen(dependencies: dependencies)
        .environment(dependencies.store)
}
