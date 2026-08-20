import Foundation
import SwiftUI

struct SettingsScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var isDeleteConfirmationPresented = false

    private let artifactRepository: any ArtifactRepository

    init() {
        self.init(dependencies: .app())
    }

    init(dependencies: AppDependencies) {
        artifactRepository = dependencies.artifacts
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    aboutSection
                    legalSection
                    dataSection
                }
                .padding(20)
            }
        }
        .navigationTitle(AppTheme.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete All Data?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete All Data", role: .destructive, action: deleteAllData)
        } message: {
            Text("This removes saved booklets, drafts, and prepared exports. Built-in templates remain available, and the app tour restarts.")
        }
    }

    private var header: some View {
        StudioSectionHeader(
            eyebrow: "Studio",
            title: "Settings",
            subtitle: "Manage this device’s booklet workspace."
        )
    }

    private var aboutSection: some View {
        settingsCard {
            Label("About", systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(AppTheme.displayName)
                .font(.body.weight(.medium))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Create thoughtful printed guides for studio visits, exhibitions, and open days.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("About \(AppTheme.displayName). Create thoughtful printed guides for studio visits, exhibitions, and open days.")
    }

    private var legalSection: some View {
        settingsCard {
            Label("Legal", systemImage: "doc.text")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(legalCopy)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .tint(AppTheme.accent)
        }
    }

    private var dataSection: some View {
        settingsCard {
            Label("Data", systemImage: "externaldrive")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text("Remove saved booklets, drafts, and prepared exports. Built-in templates remain available.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            Button(role: .destructive) {
                isDeleteConfirmationPresented = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
            }
            .accessibilityHint("Presents a confirmation before deleting your local data.")
        }
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .studioPanel(emphasized: true)
    }

    private var legalCopy: AttributedString {
        var copy = AttributedString("Your work remains on this device. Read our ")
        var privacy = AttributedString("Privacy Policy")
        var terms = AttributedString("Terms of Use")

        if let url = Legal.privacy {
            privacy.link = url
        }

        if let url = Legal.terms {
            terms.link = url
        }

        copy.append(privacy)
        copy.append(AttributedString(" and "))
        copy.append(terms)
        copy.append(AttributedString("."))
        return copy
    }

    private func deleteAllData() {
        artifactRepository.resetArtifacts()
        store.resetForDeletion()
        let exportsDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("OpenStudioPress-Exports", isDirectory: true)
        try? FileManager.default.removeItem(at: exportsDirectory)
    }
}

#Preview {
    SettingsScreen(dependencies: .preview())
        .environment(AppDependencies.preview().store)
}
