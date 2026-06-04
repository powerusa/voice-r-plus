import SwiftUI

struct PermissionView: View {
    let requestPermission: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)

            VStack(spacing: 10) {
                Text("Microphone Access Needed")
                    .font(.title2.bold())

                Text("Voice R+ needs microphone access to record your voice notes.")
                    .font(.body)
                    .foregroundStyle(.secondary)
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

            Button("Try Again", action: requestPermission)
                .buttonStyle(.borderless)
        }
        .padding(28)
    }
}

#Preview {
    PermissionView {}
}
