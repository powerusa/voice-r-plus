import SwiftUI

struct RecordButtonView: View {
    let isRecording: Bool
    let isPaused: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(activeColor.opacity(isRecording ? 0.15 : 0.10))
                    .frame(width: 132, height: 132)
                    .overlay {
                        Circle()
                            .stroke(activeColor.opacity(isRecording ? 0.24 : 0.12), lineWidth: 10)
                            .blur(radius: 10)
                    }

                Circle()
                    .stroke(activeColor.opacity(isRecording && !isPaused ? 0.32 : 0.14), lineWidth: 2)
                    .frame(width: 118, height: 118)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: activeColor.opacity(0.32), radius: 24, y: 12)

                Image(systemName: symbolName)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(isRecording && !isPaused ? 1.04 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isRecording)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var symbolName: String {
        if isRecording && !isPaused { return "pause.fill" }
        if isRecording && isPaused { return "play.fill" }
        return "mic.fill"
    }

    private var activeColor: Color {
        if isRecording && isPaused { return .blue }
        return .red
    }

    private var gradientColors: [Color] {
        if isRecording && isPaused { return [.blue, .cyan] }
        return [.red, .pink]
    }

    private var accessibilityLabel: String {
        if isRecording && !isPaused { return "Pause recording" }
        if isRecording && isPaused { return "Resume recording" }
        return "Start recording"
    }
}

#Preview {
    VStack(spacing: 24) {
        RecordButtonView(isRecording: false, isPaused: false) {}
        RecordButtonView(isRecording: true, isPaused: false) {}
    }
    .padding()
}
