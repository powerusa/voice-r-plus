import SwiftUI

struct PermissionView: View {
    let requestPermission: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)

            VStack(spacing: 10) {
                Text("Microphone Access Needed")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Voice R+ needs microphone access to record your voice notes.")
                    .font(.body)
                    .foregroundStyle(Color.white.opacity(0.64))
                    .multilineTextAlignment(.center)
            }

            Button {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            } label: {
                Label("Open Settings", systemImage: "gearshape.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            Button("Try Again", action: requestPermission)
                .buttonStyle(.borderless)
                .foregroundStyle(.cyan)
        }
        .padding(28)
        .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.cyan.opacity(0.22), lineWidth: 1)
        }
    }
}

#Preview {
    PermissionView {}
}
