import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            SynthwaveBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 34) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 168, height: 168)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.34), lineWidth: 1)
                    }

                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 112))
                    .foregroundStyle(.red, .pink)
            }

            VStack(spacing: 14) {
                Text("Voice R+")
                    .font(.system(size: 42, weight: .bold, design: .rounded))

                Text("Record voice notes, meetings, ideas, and reminders directly on your device.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(spacing: 12) {
                Label("Your recordings stay on your device.", systemImage: "lock.fill")
                Label("Save, rename, share, and play back anytime.", systemImage: "square.and.arrow.up.fill")
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            Spacer()

            Button {
                hasSeenOnboarding = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(28)
        }
    }
}

#Preview {
    OnboardingView()
}
