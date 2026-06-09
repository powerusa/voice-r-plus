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
                    .fill(Color.black.opacity(0.28))
                    .frame(width: 168, height: 168)
                    .overlay {
                        Circle()
                            .stroke(Color.cyan.opacity(0.32), lineWidth: 1)
                    }

                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 112))
                    .foregroundStyle(.orange, .cyan)
            }

            VStack(spacing: 14) {
                Text("Voice R+")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Record voice notes, meetings, ideas, and reminders directly on your device.")
                    .font(.title3)
                    .foregroundStyle(Color.white.opacity(0.64))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(spacing: 12) {
                Label("Your recordings stay on your device.", systemImage: "lock.fill")
                Label("Save, rename, share, and play back anytime.", systemImage: "square.and.arrow.up.fill")
            }
            .font(.callout)
            .foregroundStyle(Color.white.opacity(0.62))

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
            .tint(.orange)
            .controlSize(.large)
        }
        .padding(28)
        }
    }
}

#Preview {
    OnboardingView()
}
