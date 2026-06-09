import SwiftUI

struct RecordingRowView: View {
    let recording: Recording

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.34))
                    .frame(width: 54, height: 54)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.cyan.opacity(0.28), lineWidth: 1)
                    }

                Image(systemName: "waveform")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.cyan, .orange)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(recording.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(TimeFormatter.date(recording.createdAt))
                }
                .font(.caption.monospaced())
                .foregroundStyle(Color.white.opacity(0.52))
            }

            Spacer(minLength: 12)

            Text(TimeFormatter.duration(recording.duration))
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(Color.orange.opacity(0.92))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.12), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(Color.orange.opacity(0.24), lineWidth: 1)
                }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.black.opacity(0.30)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.13), lineWidth: 1)
        }
    }
}

#Preview {
    RecordingRowView(recording: .preview)
        .padding()
        .background(Color.black)
}
