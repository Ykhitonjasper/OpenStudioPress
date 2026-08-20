import SwiftUI

/// Studio-only chrome kept out of the generic AppTheme template.
/// Chromatic values live in the asset catalog — no literal RGB here.
extension AppTheme {
    /// Printed-page surface on the dark board chrome.
    static let paper = Color("Paper")
    static let paperInk = Color("PaperInk")
    static let foil = Color("Foil")
    static let roseDeep = Color("RoseDeep")
    static let accentSoft = Color("AccentSoft")
    static let panelFillHigh = Color("PanelFillHigh")
    static let panelFillLow = Color("PanelFillLow")

    static let cornerRadius: CGFloat = 26
    static let panelPadding: CGFloat = 20

    static var displayFont: Font {
        .system(size: 34, weight: .semibold, design: .serif)
    }

    static var titleFont: Font {
        .system(size: 24, weight: .semibold, design: .serif)
    }

    static var eyebrowFont: Font {
        .system(size: 11, weight: .bold, design: .rounded)
    }

    static var accentSheen: LinearGradient {
        LinearGradient(
            colors: [accentSoft, accent, roseDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var foilSheen: LinearGradient {
        LinearGradient(
            colors: [foil.opacity(0.95), accentSoft.opacity(0.85), foil.opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var panelFill: LinearGradient {
        LinearGradient(
            colors: [panelFillHigh.opacity(0.94), panelFillLow.opacity(0.98)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var rimStroke: LinearGradient {
        LinearGradient(
            colors: [
                foil.opacity(0.55),
                accent.opacity(0.55),
                hairline.opacity(0.85),
                foil.opacity(0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct StudioSectionHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Capsule()
                    .fill(AppTheme.foilSheen)
                    .frame(width: 28, height: 2)
                Text(eyebrow.uppercased())
                    .font(AppTheme.eyebrowFont)
                    .tracking(2.4)
                    .foregroundStyle(AppTheme.textMono)
            }

            Text(title)
                .font(AppTheme.displayFont)
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(2)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct StudioBrandMark: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.accentSheen)
                    .frame(width: 36, height: 36)
                    .shadow(color: AppTheme.accent.opacity(0.4), radius: 10, y: 4)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("OPEN STUDIO")
                    .font(AppTheme.eyebrowFont)
                    .tracking(2.2)
                    .foregroundStyle(AppTheme.textMono)
                Text("Press")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AppTheme.displayName)
    }
}

struct StudioPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

extension View {
    func studioPanel(padding: CGFloat = AppTheme.panelPadding, emphasized: Bool = false) -> some View {
        self
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .fill(AppTheme.panelFill)

                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    .clear,
                                    Color.black.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)

                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .stroke(AppTheme.rimStroke, lineWidth: emphasized ? 1.25 : 1)

                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius - 3, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                        .padding(3)
                }
                .shadow(color: Color.black.opacity(0.35), radius: 22, y: 14)
                .shadow(color: AppTheme.accent.opacity(emphasized ? 0.28 : 0.14), radius: emphasized ? 28 : 18, y: 10)
            }
    }

    func studioPrimaryLabel() -> some View {
        self
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.accentSheen)
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: AppTheme.accent.opacity(0.45), radius: 20, y: 10)
                .shadow(color: AppTheme.roseDeep.opacity(0.35), radius: 8, y: 4)
            }
    }

    func studioSecondaryLabel() -> some View {
        self
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.bgElevated.opacity(0.85))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.rimStroke, lineWidth: 1)
                    }
            }
    }

    func studioField() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.28))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.hairline.opacity(0.9), lineWidth: 1)
                    }
            }
            .foregroundStyle(AppTheme.textPrimary)
            .tint(AppTheme.accent)
    }
}
