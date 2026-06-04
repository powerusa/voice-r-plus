import SwiftUI

struct SynthwaveBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)

            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(colorScheme == .dark ? 0.08 : 0.94),
                    Color.blue.opacity(colorScheme == .dark ? 0.18 : 0.10),
                    Color.purple.opacity(colorScheme == .dark ? 0.16 : 0.08),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.blue.opacity(colorScheme == .dark ? 0.22 : 0.13))
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: -160, y: -260)

            Circle()
                .fill(Color.purple.opacity(colorScheme == .dark ? 0.22 : 0.11))
                .frame(width: 360, height: 360)
                .blur(radius: 82)
                .offset(x: 180, y: 270)

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(colorScheme == .dark ? 0.08 : 0.24)
        }
    }
}

#Preview {
    SynthwaveBackgroundView()
}
