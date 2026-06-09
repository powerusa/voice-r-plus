import SwiftUI

struct RecordButtonView: View {
    let isRecording: Bool
    let isPaused: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(activeColor.opacity(isRecording ? 0.18 : 0.10))
                    .frame(width: 138, height: 138)
                    .overlay {
                        Circle()
                            .stroke(activeColor.opacity(isRecording ? 0.34 : 0.16), lineWidth: 8)
                            .blur(radius: 8)
                    }

                Circle()
                    .stroke(activeColor.opacity(isRecording && !isPaused ? 0.76 : 0.34), style: StrokeStyle(lineWidth: 2, dash: [9, 7]))
                    .frame(width: 126, height: 126)

                Circle()
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    .frame(width: 108, height: 108)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.34), lineWidth: 1)
                    }
                    .shadow(color: activeColor.opacity(0.42), radius: 24, y: 12)

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
        if isRecording && isPaused { return .cyan }
        if isRecording { return .red }
        return .orange
    }

    private var gradientColors: [Color] {
        if isRecording && isPaused { return [.cyan, .blue] }
        if isRecording { return [.red, .orange] }
        return [.orange, .red]
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
