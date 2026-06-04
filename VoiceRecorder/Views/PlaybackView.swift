import SwiftUI

struct PlaybackView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PlayerViewModel

    let onRename: (Recording, String) -> Void
    let onDelete: (Recording) -> Void

    @State private var showRenameAlert = false
    @State private var renameText: String
    @State private var showDeleteConfirmation = false

    init(
        recording: Recording,
        onRename: @escaping (Recording, String) -> Void,
        onDelete: @escaping (Recording) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: PlayerViewModel(recording: recording))
        self.onRename = onRename
        self.onDelete = onDelete
        _renameText = State(initialValue: recording.name)
    }

    var body: some View {
        ZStack {
            SynthwaveBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    heroCard
                    transportCard
                    actionCard

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Playback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Rename Recording", isPresented: $showRenameAlert) {
            TextField("Name", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                let trimmedName = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedName.isEmpty else { return }
                onRename(viewModel.recording, trimmedName)
                viewModel.recording.name = trimmedName
            }
        }
        .confirmationDialog("Delete this recording?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                viewModel.stop()
                onDelete(viewModel.recording)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var heroCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 118, height: 118)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.36), lineWidth: 1)
                    }

                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(.red, .pink)
            }

            Text(viewModel.recording.name)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(3)

            HStack(spacing: 10) {
                Label(TimeFormatter.date(viewModel.recording.createdAt), systemImage: "calendar")
                Label(TimeFormatter.duration(viewModel.recording.duration), systemImage: "clock")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .glassCard()
    }

    private var transportCard: some View {
        VStack(spacing: 16) {
            Slider(
                value: Binding(
                    get: { viewModel.currentTime },
                    set: { viewModel.seek(to: $0) }
                ),
                in: 0...max(viewModel.duration, 1)
            )

            HStack {
                Text(TimeFormatter.duration(viewModel.currentTime))
                Spacer()
                Text(TimeFormatter.duration(viewModel.duration))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)

            HStack(spacing: 34) {
                Button {
                    viewModel.skipBackward()
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 34))
                }
                .accessibilityLabel("Skip backward 15 seconds")

                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 76))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.red)
                }
                .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

                Button {
                    viewModel.skipForward()
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 34))
                }
                .accessibilityLabel("Skip forward 15 seconds")
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .glassCard()
    }

    private var actionCard: some View {
        VStack(spacing: 12) {
            Button {
                renameText = viewModel.recording.name
                showRenameAlert = true
            } label: {
                Label("Rename", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            ShareLink(item: viewModel.recording.fileURL) {
                Label("Share Recording", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.errorMessage != nil)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(18)
        .glassCard()
    }
}

private extension View {
    func glassCard() -> some View {
        background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.26), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.07), radius: 20, y: 12)
    }
}

#Preview {
    NavigationStack {
        PlaybackView(
            recording: .preview,
            onRename: { _, _ in },
            onDelete: { _ in }
        )
    }
}
