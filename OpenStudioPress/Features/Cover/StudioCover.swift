import SwiftUI

struct StudioCover: View {
    private let booklet = StudioSeedData.artifacts()[0]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    StudioSectionHeader(
                        eyebrow: "Atelier",
                        title: booklet.title,
                        subtitle: "\(AppTheme.displayName) · visitor booklet on this iPhone"
                    )

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 150), spacing: 14)],
                        spacing: 14
                    ) {
                        coverTile(
                            title: "Stops",
                            value: "\(booklet.blockIDs.count)",
                            caption: "On this route",
                            symbol: "rectangle.3.group"
                        )
                        coverTile(
                            title: "Size",
                            value: booklet.size.label,
                            caption: "Press format",
                            symbol: "doc.plaintext"
                        )
                        coverTile(
                            title: "Density",
                            value: booklet.density.label,
                            caption: "Reading pace",
                            symbol: "text.alignleft"
                        )
                        coverTile(
                            title: "Rhythm",
                            value: booklet.foldRhythm.label,
                            caption: "Page turns",
                            symbol: "book.closed"
                        )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Quick tools")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)

                        toolRow(title: "Start blank", detail: "Clear the forme and open a new brief", symbol: "square.dashed")
                        toolRow(title: "Templates", detail: "First Open Studio · half letter", symbol: "rectangle.stack")
                        toolRow(title: "Library", detail: "Clay & Ash ready to revisit", symbol: "books.vertical")

                        Text("Briefs stay on this iPhone.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .studioPanel()
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppTheme.displayName)
    }

    private func coverTile(title: String, value: String, caption: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityHidden(true)
                Text(title.uppercased())
                    .font(AppTheme.eyebrowFont)
                    .tracking(1.2)
                    .foregroundStyle(AppTheme.textMono)
            }

            Text(value)
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.textPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(caption)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .studioPanel(padding: 16)
    }

    private func toolRow(title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    StudioCover()
}
