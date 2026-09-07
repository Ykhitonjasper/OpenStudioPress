import SwiftUI

struct BrandedSplash: View {
    let progress: Double
    var veil: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    private var splashMessage: String {
        LaunchSplashCopy.message(for: progress)
    }

    var body: some View {
        ZStack {
            AppTheme.bgBase
                .ignoresSafeArea()
                .opacity(veil)
                .blur(radius: reduceMotion ? 0 : veilBlur)

            Circle()
                .fill(AppTheme.backgroundGlow.opacity(glowOpacity * chromeOpacity))
                .frame(width: 220, height: 220)
                .blur(radius: 56)
                .scaleEffect(1 + (1 - veil) * 0.12)
                .opacity(chromeOpacity)

            VStack(spacing: 36) {
                StudioBrandMark()
                    .scaleEffect(markScale)
                    .opacity(revealed ? chromeOpacity : 0)

                VStack(spacing: 18) {
                    Text(splashMessage)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .contentTransition(.opacity)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: splashMessage)

                    VStack(spacing: 10) {
                        LaunchProgressBar(progress: progress)

                        Text(progressLabel)
                            .font(.caption2.monospacedDigit().weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary.opacity(0.85))
                            .opacity(progress >= 0.995 ? 0 : 1)
                    }
                    .frame(maxWidth: 240)
                }
            }
            .padding(.horizontal, 32)
            .scaleEffect(chromeScale)
            .opacity(chromeOpacity)
            .offset(y: chromeLift)
            .blur(radius: reduceMotion ? 0 : chromeBlur)
        }
        .allowsHitTesting(veil > 0.05)
        .onAppear {
            guard !reduceMotion else {
                revealed = true
                return
            }
            withAnimation(.easeOut(duration: 0.55)) {
                revealed = true
            }
        }
    }

    private var chromeOpacity: Double {
        LaunchRevealMath.chromeOpacity(veil: veil)
    }

    private var chromeScale: CGFloat {
        CGFloat(1 + (1 - LaunchRevealMath.chromeOpacity(veil: veil)) * 0.045)
    }

    private var chromeLift: CGFloat {
        CGFloat((1 - LaunchRevealMath.chromeOpacity(veil: veil)) * -10)
    }

    private var chromeBlur: CGFloat {
        CGFloat((1 - LaunchRevealMath.chromeOpacity(veil: veil)) * 6)
    }

    private var markScale: CGFloat {
        (revealed ? 1 : 0.92) * chromeScale
    }

    private var veilBlur: CGFloat {
        CGFloat(sin(veil * .pi) * 14)
    }

    private var glowOpacity: Double {
        0.22 + (progress * 0.38)
    }

    private var progressLabel: String {
        "\(Int((progress * 100).rounded()))%"
    }
}

struct WarmOverlay: View {
    let progress: Double
    var veil: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            AppTheme.bgBase
                .ignoresSafeArea()
                .opacity(veil)
                .blur(radius: reduceMotion ? 0 : CGFloat(sin(veil * .pi) * 10))

            VStack(spacing: 18) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppTheme.accent)

                LaunchProgressBar(progress: progress)
                    .frame(maxWidth: 160)

                Text("\(Int((progress * 100).rounded()))%")
                    .font(.caption2.monospacedDigit().weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .opacity(progress >= 0.995 ? 0 : 1)
            }
            .padding(.vertical, 60)
            .scaleEffect(1 + (1 - LaunchRevealMath.chromeOpacity(veil: veil)) * 0.04)
            .opacity(LaunchRevealMath.chromeOpacity(veil: veil))
            .offset(y: CGFloat((1 - LaunchRevealMath.chromeOpacity(veil: veil)) * -8))
            .blur(radius: reduceMotion ? 0 : CGFloat((1 - LaunchRevealMath.chromeOpacity(veil: veil)) * 5))
        }
        .allowsHitTesting(veil > 0.05)
    }
}

struct WarmScrim: View {
    let progress: Double
    var veil: Double = 1

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    AppTheme.bgBase.opacity(0.97 * veil),
                    AppTheme.bgBase.opacity(0.88 * veil),
                    AppTheme.bgBase.opacity(0.55 * veil)
                ],
                center: .center,
                startRadius: 40,
                endRadius: 520
            )
            .ignoresSafeArea()
            .blur(radius: reduceMotion ? 0 : CGFloat(sin(veil * .pi) * 8))

            VStack(spacing: 12) {
                LaunchProgressBar(progress: progress)
                    .frame(maxWidth: 120)

                Text("\(Int((progress * 100).rounded()))%")
                    .font(.caption2.monospacedDigit().weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.9))
                    .opacity(progress >= 0.995 ? 0 : 1)
            }
            .opacity(LaunchRevealMath.chromeOpacity(veil: veil))
            .scaleEffect(1 + (1 - LaunchRevealMath.chromeOpacity(veil: veil)) * 0.03)
            .blur(radius: reduceMotion ? 0 : CGFloat((1 - LaunchRevealMath.chromeOpacity(veil: veil)) * 4))
        }
        .allowsHitTesting(veil > 0.05)
    }
}

struct LaunchProgressBar: View {
    let progress: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.hairline.opacity(0.28))

                Capsule()
                    .fill(AppTheme.foilSheen)
                    .frame(width: max(0, geometry.size.width * clampedProgress))
                    .shadow(
                        color: AppTheme.accent.opacity(clampedProgress > 0.08 ? 0.35 : 0),
                        radius: 6,
                        y: 0
                    )
            }
        }
        .frame(height: 4)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.4), value: clampedProgress)
    }

    private var clampedProgress: CGFloat {
        CGFloat(min(1, max(0, progress)))
    }
}

enum LaunchRevealMath {
    static func chromeOpacity(veil: Double) -> Double {
        let t = min(1, max(0, (veil - 0.28) / 0.72))
        return t * t * (3 - 2 * t)
    }
}
