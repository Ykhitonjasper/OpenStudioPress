import Observation
import SwiftUI

struct TemplatesGalleryScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var viewModel: ViewModel

    init() {
        self.init(dependencies: .app())
    }

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: ViewModel(repository: dependencies.templates))
    }

    var body: some View {
        ZStack {
            AppBackground()

            if viewModel.filteredTemplates.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        filters
                        templateGrid
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(AppTheme.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search templates")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            StudioSectionHeader(
                eyebrow: "Press Room",
                title: "Templates",
                subtitle: "\(viewModel.filteredTemplates.count) of \(viewModel.templates.count) editorial starters for a clear studio visit."
            )

            Button(action: startFirstTemplate) {
                Label("Start with First Open Studio", systemImage: "sparkles")
                    .studioPrimaryLabel()
            }
            .buttonStyle(StudioPressStyle())
            .accessibilityHint("Starts a new booklet using the First Open Studio template.")
        }
        .accessibilityElement(children: .contain)
    }

    private var filters: some View {
        HStack(spacing: 12) {
            Menu {
                Button("All sizes") {
                    viewModel.selectedSize = nil
                }

                ForEach(BookletSize.allCases, id: \.self) { size in
                    Button(size.label) {
                        viewModel.selectedSize = size
                    }
                }
            } label: {
                filterLabel(
                    title: "Size",
                    value: viewModel.selectedSize?.label ?? "All"
                )
            }
            .accessibilityLabel("Filter by size: \(viewModel.selectedSize?.label ?? "All sizes")")

            Menu {
                Button("All densities") {
                    viewModel.selectedDensity = nil
                }

                ForEach(ReadingDensity.allCases, id: \.self) { density in
                    Button(density.label) {
                        viewModel.selectedDensity = density
                    }
                }
            } label: {
                filterLabel(
                    title: "Density",
                    value: viewModel.selectedDensity?.label ?? "All"
                )
            }
            .accessibilityLabel("Filter by density: \(viewModel.selectedDensity?.label ?? "All densities")")

            Spacer(minLength: 0)
        }
    }

    private var templateGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 160), spacing: 14)],
            spacing: 14
        ) {
            ForEach(viewModel.filteredTemplates) { template in
                templateCard(for: template)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No matching templates", systemImage: "rectangle.stack.badge.minus")
        } description: {
            Text("Try a different search or clear the filters to browse all fifteen editorial starters.")
        } actions: {
            Button("Show all templates", action: viewModel.clearFilters)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .accessibilityHint("Clears the search and template filters.")
        }
        .foregroundStyle(AppTheme.textPrimary)
        .padding()
    }

    private func filterLabel(title: String, value: String) -> some View {
        Label("\(title): \(value)", systemImage: "line.3.horizontal.decrease.circle")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.bgElevated, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(AppTheme.hairline, lineWidth: 1)
            }
    }

    private func templateCard(for template: Template) -> some View {
        Button {
            store.route = .templateDetail(template.id)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.accent)
                        .accessibilityHidden(true)

                    Spacer()

                    Text("\(template.blockIDs.count) blocks")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.textMono)
                }

                Spacer(minLength: 8)

                Text(template.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(template.summary)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(template.size.label) · \(template.density.label)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.textMono)
            }
            .frame(maxWidth: .infinity, minHeight: 210, alignment: .leading)
            .studioPanel(emphasized: true)
        }
        .buttonStyle(StudioPressStyle())
        .accessibilityLabel("\(template.title), \(template.summary), \(template.size.label), \(template.density.label), \(template.blockIDs.count) blocks")
        .accessibilityHint("Opens the template preview and use action.")
    }

    private func startFirstTemplate() {
        guard let template = viewModel.templates.first(where: { $0.title == "First Open Studio" }) else {
            return
        }

        store.route = .templateDetail(template.id)
    }

    @MainActor
    @Observable
    final class ViewModel {
        let templates: [Template]
        var searchText = ""
        var selectedSize: BookletSize?
        var selectedDensity: ReadingDensity?

        init(repository: any TemplateRepository) {
            templates = repository.templates()
        }

        var filteredTemplates: [Template] {
            templates.filter { template in
                let matchesSearch = searchText.isEmpty
                    || template.title.localizedCaseInsensitiveContains(searchText)
                    || template.summary.localizedCaseInsensitiveContains(searchText)
                let matchesSize = selectedSize == nil || template.size == selectedSize
                let matchesDensity = selectedDensity == nil || template.density == selectedDensity
                return matchesSearch && matchesSize && matchesDensity
            }
        }

        func clearFilters() {
            searchText = ""
            selectedSize = nil
            selectedDensity = nil
        }
    }
}

#Preview {
    TemplatesGalleryScreen(dependencies: .preview())
        .environment(AppDependencies.preview().store)
}
