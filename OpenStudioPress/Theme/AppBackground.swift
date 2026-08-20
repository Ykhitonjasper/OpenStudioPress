import SwiftUI

struct AppBackground: View {
    @State private var shimmer = false

    var body: some View {
        ZStack {
            AppTheme.bgBase

            // Upper salon wash — rose to champagne.
            RadialGradient(
                colors: [
                    Color(red: 0.92, green: 0.35, blue: 0.55).opacity(0.42),
                    Color(red: 0.58, green: 0.16, blue: 0.36).opacity(0.2),
                    .clear
                ],
                center: UnitPoint(x: 0.86, y: -0.02),
                startRadius: 8,
                endRadius: 520
            )

            // Soft foil bloom lower-left.
            RadialGradient(
                colors: [
                    AppTheme.foil.opacity(0.14),
                    Color(red: 0.96, green: 0.72, blue: 0.82).opacity(0.1),
                    .clear
                ],
                center: UnitPoint(x: 0.08, y: 0.78),
                startRadius: 6,
                endRadius: 360
            )

            // Mid velvet vignette.
            RadialGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.55)
                ],
                center: .center,
                startRadius: 120,
                endRadius: 520
            )

            LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.12, blue: 0.20).opacity(0.12),
                    Color(red: 0.04, green: 0.02, blue: 0.05).opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Slow diagonal silk sheen.
            LinearGradient(
                colors: [
                    Color.white.opacity(shimmer ? 0.07 : 0.03),
                    .clear,
                    AppTheme.foil.opacity(shimmer ? 0.05 : 0.02),
                    .clear
                ],
                startPoint: shimmer ? .topLeading : UnitPoint(x: -0.2, y: 0.2),
                endPoint: shimmer ? .bottomTrailing : UnitPoint(x: 1.2, y: 0.8)
            )
            .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: shimmer)
        }
        .ignoresSafeArea()
        .onAppear { shimmer = true }
    }
}

#Preview {
    AppBackground()
}
