import SwiftUI

struct RecordingRowView: View {
    let recording: Recording

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.thinMaterial)
                    .frame(width: 54, height: 54)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.28), lineWidth: 1)
                    }

                Image(systemName: "waveform")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue, .purple)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(recording.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(TimeFormatter.date(recording.createdAt))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Text(TimeFormatter.duration(recording.duration))
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.34), lineWidth: 1)
        }
    }
}

#Preview {
    RecordingRowView(recording: .preview)
        .padding()
        .background(Color(.systemGroupedBackground))
}
