import Observation
import SwiftUI

struct CreateBriefScreen: View {
    @State private var model: CreateBriefModel

    init(dependencies: AppDependencies) {
        _model = State(initialValue: CreateBriefModel(
            templates: dependencies.templates.templates(),
            store: dependencies.store
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    StudioSectionHeader(
                        eyebrow: "Atelier",
                        title: "Create a booklet",
                        subtitle: "Start with a blank structure or adapt one of the studio templates."
                    )

                    startingPath
                    bookletDetails
                    templateChoices
                    continueButton
                }
                .padding(20)
                .padding(.bottom, 28)
            }
            .background(AppBackground())
            .navigationTitle(AppTheme.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var startingPath: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Starting point")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Button(action: model.startBlank) {
                Label("Start blank", systemImage: "square.dashed")
                    .studioSecondaryLabel()
            }
            .buttonStyle(StudioPressStyle())
            .accessibilityHint("Clears the selected template and starts with a blank booklet.")
        }
        .studioPanel()
    }

    private var bookletDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Booklet details")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            TextField("Booklet title", text: $model.title)
                .studioField()
                .accessibilityLabel("Booklet title")

            VStack(alignment: .leading, spacing: 8) {
                Text("Size")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textMono)
                Picker("Size", selection: $model.size) {
                    ForEach(BookletSize.allCases, id: \.self) { size in
                        Text(size.label).tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Booklet size")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Reading density")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textMono)
                Picker("Reading density", selection: $model.density) {
                    ForEach(ReadingDensity.allCases, id: \.self) { density in
                        Text(density.label).tag(density)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Reading density")
            }
        }
        .studioPanel(emphasized: true)
    }

    private var templateChoices: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Templates")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(model.templates.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.foil)
            }

            ForEach(model.templates) { template in
                Button {
                    model.choose(template)
                } label: {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: model.selectedTemplateID == template.id ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(model.selectedTemplateID == template.id ? AnyShapeStyle(AppTheme.accentSheen) : AnyShapeStyle(AppTheme.textSecondary))
                        VStack(alignment: .leading, spacing: 6) {
                            Text(template.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(template.summary)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineSpacing(2)
                            Text("\(template.size.label) · \(template.density.label)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.textMono)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .studioPanel(emphasized: model.selectedTemplateID == template.id)
                }
                .buttonStyle(StudioPressStyle())
                .accessibilityLabel("\(template.title), \(template.size.label), \(template.density.label)")
                .accessibilityHint("Uses this template as the starting point for the booklet.")
                .accessibilityAddTraits(model.selectedTemplateID == template.id ? .isSelected : [])
            }
        }
    }

    private var continueButton: some View {
        Button(action: model.continueToShelf) {
            Label("Choose blocks", systemImage: "rectangle.stack.badge.plus")
                .studioPrimaryLabel()
        }
        .buttonStyle(StudioPressStyle())
        .disabled(!model.canContinue)
        .opacity(model.canContinue ? 1 : 0.42)
        .accessibilityHint(model.canContinue ? "Saves this booklet brief and opens block choices." : "Enter a booklet title to continue.")
    }
}

@MainActor
@Observable
private final class CreateBriefModel {
    let templates: [Template]
    private let store: StudioAppStore

    var title = ""
    var size: BookletSize = .halfLetter
    var density: ReadingDensity = .balanced
    var selectedTemplateID: String?

    init(templates: [Template], store: StudioAppStore) {
        self.templates = templates
        self.store = store
    }

    var canContinue: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func startBlank() {
        title = ""
        size = .halfLetter
        density = .balanced
        selectedTemplateID = nil
    }

    func choose(_ template: Template) {
        title = template.title
        size = template.size
        density = template.density
        selectedTemplateID = template.id
    }

    func continueToShelf() {
        let brief = CreateBrief(
            id: "draft-current",
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            size: size,
            templateID: selectedTemplateID,
            density: density,
            foldRhythm: .paired
        )
        store.brief = brief
        store.route = .blockShelf(brief.id)
    }
}

#Preview {
    CreateBriefScreen(dependencies: .preview())
}
