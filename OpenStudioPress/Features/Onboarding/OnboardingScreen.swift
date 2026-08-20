import SwiftUI

struct OnboardingScreen: View {
    @Environment(StudioAppStore.self) private var store
    @State private var currentPage = 0
    @State private var appear = false

    private let tourPages = [
        (
            symbol: "rectangle.3.group.fill",
            eyebrow: "BUILD A ROUTE",
            title: "Shape a booklet around the work",
            detail: "Start with a brief, select the moments visitors should notice, then arrange them into a clear reading path."
        ),
        (
            symbol: "internaldrive.fill",
            eyebrow: "KEEP IT CLOSE",
            title: "Your work stays on this device",
            detail: "Briefs, blocks, and assembled booklets are saved locally, so you can refine a visit whenever the studio is ready."
        ),
        (
            symbol: "square.and.arrow.up.fill",
            eyebrow: "SHARE THE VISIT",
            title: "Give visitors a guide to carry",
            detail: "Check the flow, then export a print-ready booklet or a simple text guide for an approachable visit."
        )
    ]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 26) {
                HStack(alignment: .center) {
                    StudioBrandMark()
                    Spacer()
                    Text("\(currentPage + 1) / \(tourPages.count)")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(AppTheme.foil)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background {
                            Capsule()
                                .fill(Color.black.opacity(0.28))
                                .overlay(Capsule().stroke(AppTheme.rimStroke, lineWidth: 1))
                        }
                        .accessibilityLabel("Tour page \(currentPage + 1) of \(tourPages.count)")
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 12)

                TabView(selection: $currentPage) {
                    ForEach(Array(tourPages.enumerated()), id: \.offset) { index, page in
                        VStack(alignment: .leading, spacing: 20) {
                            Spacer(minLength: 8)

                            ZStack {
                                Circle()
                                    .fill(AppTheme.accent.opacity(0.12))
                                    .frame(width: 104, height: 104)
                                Circle()
                                    .stroke(AppTheme.rimStroke, lineWidth: 1)
                                    .frame(width: 104, height: 104)
                                Circle()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                                    .frame(width: 88, height: 88)
                                Image(systemName: page.symbol)
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundStyle(AppTheme.accentSheen)
                                    .accessibilityHidden(true)
                            }
                            .shadow(color: AppTheme.accent.opacity(0.25), radius: 20, y: 8)

                            Text(page.eyebrow)
                                .font(AppTheme.eyebrowFont)
                                .tracking(2)
                                .foregroundStyle(AppTheme.textMono)

                            Text(page.title)
                                .font(AppTheme.displayFont)
                                .foregroundStyle(AppTheme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(page.detail)
                                .font(.body)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: 8)
                        }
                        .padding(24)
                        .studioPanel(padding: 0, emphasized: true)
                        .padding(.horizontal, 2)
                        .tag(index)
                        .accessibilityElement(children: .combine)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .accessibilityLabel("\(AppTheme.displayName) tour")
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 18)

                Button(action: continueTour) {
                    Text(currentPage == tourPages.indices.last ? "Start Creating" : "Continue")
                        .studioPrimaryLabel()
                }
                .buttonStyle(StudioPressStyle())
                .accessibilityLabel(currentPage == tourPages.indices.last ? "Finish tour and open Create" : "Continue to the next tour page")
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 10)
            }
            .padding(24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.86)) {
                appear = true
            }
        }
        .sensoryFeedback(.success, trigger: store.hasCompletedOnboarding)
        .sensoryFeedback(.selection, trigger: currentPage)
    }

    private func continueTour() {
        if currentPage == tourPages.indices.last {
            store.selectedTab = .create
            store.hasCompletedOnboarding = true
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                currentPage += 1
            }
        }
    }
}

#Preview {
    OnboardingScreen()
        .environment(StudioAppStore())
}
