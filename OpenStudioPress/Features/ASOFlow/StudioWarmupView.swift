import SwiftUI

/// Startup splash while StartupRouter resolves native vs experiment.
struct StudioWarmupView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                AppBackground()

                roseGlowField(time: t)

                VStack(spacing: 44) {
                    StudioBrandMark()
                        .scaleEffect(0.92 + pulse(t, speed: 1.4) * 0.04)

                    BookletPressAnimation(time: t)
                        .frame(width: 220, height: 200)

                    FoilProgressRail(time: t)
                        .frame(width: 168, height: 4)
                }
                .padding(.horizontal, 32)
            }
        }
    }

    private func roseGlowField(time: TimeInterval) -> some View {
        ZStack {
            Circle()
                .fill(AppTheme.accent.opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 48)
                .offset(x: sin(time * 0.7) * 28, y: cos(time * 0.55) * 22)

            Circle()
                .fill(AppTheme.roseDeep.opacity(0.1))
                .frame(width: 260, height: 260)
                .blur(radius: 40)
                .offset(x: cos(time * 0.6) * -24, y: sin(time * 0.8) * 30)
        }
    }

    private func pulse(_ time: TimeInterval, speed: Double) -> CGFloat {
        CGFloat((sin(time * speed) + 1) / 2)
    }
}

private struct BookletPressAnimation: View {
    let time: TimeInterval

    private let spreads: [(x: CGFloat, y: CGFloat, rotation: Double, delay: Double)] = [
        (-34, 18, -14, 0.0),
        (0, 0, 0, 0.35),
        (34, -16, 12, 0.7)
    ]

    var body: some View {
        ZStack {
            ForEach(Array(spreads.enumerated()), id: \.offset) { index, spread in
                let cycle = (time + spread.delay).truncatingRemainder(dividingBy: 2.4) / 2.4
                let lift = sin(cycle * .pi) * 18
                let settle = 1 - abs(sin(cycle * .pi))

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.panelFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.rimStroke, lineWidth: 1.2)
                    }
                    .overlay(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            Capsule()
                                .fill(AppTheme.accentSheen)
                                .frame(width: 36, height: 4)
                            Capsule()
                                .fill(AppTheme.hairline.opacity(0.7))
                                .frame(width: 52, height: 3)
                            Capsule()
                                .fill(AppTheme.hairline.opacity(0.45))
                                .frame(width: 44, height: 3)
                        }
                        .padding(14)
                    }
                    .frame(width: 108, height: 138)
                    .rotationEffect(.degrees(spread.rotation + sin(time * 1.1 + spread.delay) * 2))
                    .offset(
                        x: spread.x + sin(time * 0.9 + spread.delay) * 3,
                        y: spread.y - lift
                    )
                    .scaleEffect(0.94 + settle * 0.06)
                    .shadow(color: AppTheme.accent.opacity(0.18 + settle * 0.12), radius: 14, y: 8)
                    .zIndex(Double(index))
            }

            Circle()
                .stroke(AppTheme.foilSheen, lineWidth: 2)
                .frame(width: 54, height: 54)
                .scaleEffect(0.88 + CGFloat(sin(time * 2.2)) * 0.08)
                .opacity(0.55 + sin(time * 2.2) * 0.25)
                .overlay {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(AppTheme.foilSheen)
                        .rotationEffect(.degrees(time * 28))
                }
                .offset(y: 8)
        }
    }
}

private struct FoilProgressRail: View {
    let time: TimeInterval

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let travel = width + 40
            let x = (sin(time * 1.8) + 1) / 2 * travel - 20

            Capsule()
                .fill(AppTheme.hairline.opacity(0.35))

            Capsule()
                .fill(AppTheme.foilSheen)
                .frame(width: 52)
                .offset(x: x)
                .blur(radius: 0.2)
                .mask {
                    Capsule()
                }
        }
    }
}

#Preview {
    StudioWarmupView()
        .preferredColorScheme(.dark)
}
