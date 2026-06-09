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
        .toolbarColorScheme(.dark, for: .navigationBar)
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
                    .fill(Color.black.opacity(0.28))
                    .frame(width: 118, height: 118)
                    .overlay {
                        Circle()
                            .stroke(Color.cyan.opacity(0.32), lineWidth: 1)
                    }

                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(.orange, .cyan)
            }

            Text(viewModel.recording.name)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            HStack(spacing: 10) {
                Label(TimeFormatter.date(viewModel.recording.createdAt), systemImage: "calendar")
                Label(TimeFormatter.duration(viewModel.recording.duration), systemImage: "clock")
            }
            .font(.caption.monospaced().weight(.semibold))
            .foregroundStyle(Color.white.opacity(0.56))
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
            .tint(.orange)

            HStack {
                Text(TimeFormatter.duration(viewModel.currentTime))
                Spacer()
                Text(TimeFormatter.duration(viewModel.duration))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(Color.white.opacity(0.58))

            HStack(spacing: 34) {
                Button {
                    viewModel.skipBackward()
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.cyan.opacity(0.82))
                }
                .accessibilityLabel("Skip backward 15 seconds")

                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 76))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.orange)
                }
                .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

                Button {
                    viewModel.skipForward()
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 34))
                        .foregroundStyle(Color.cyan.opacity(0.82))
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
                    .font(.headline.monospaced())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.cyan.opacity(0.72))
            .controlSize(.large)

            ShareLink(item: viewModel.recording.fileURL) {
                Label("Share Recording", systemImage: "square.and.arrow.up")
                    .font(.headline.monospaced())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.orange.opacity(0.82))
            .controlSize(.large)
            .disabled(viewModel.errorMessage != nil)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.headline.monospaced())
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
        background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.09),
                    Color.black.opacity(0.34)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.38),
                                Color.white.opacity(0.10),
                                Color.orange.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.34), radius: 20, y: 12)
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
