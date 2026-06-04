import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = RecorderViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                SynthwaveBackgroundView()
                    .ignoresSafeArea()

                if viewModel.permissionState == .denied {
                    PermissionView {
                        Task { await viewModel.requestPermission() }
                    }
                    .frame(maxWidth: 440)
                    .padding(.horizontal, 20)
                } else {
                    GeometryReader { proxy in
                        let sidePadding = horizontalPadding(for: proxy.size.width)
                        let contentWidth = max(0, proxy.size.width - sidePadding * 2)

                        ScrollView {
                            VStack(alignment: .leading, spacing: contentWidth < 360 ? 14 : 18) {
                                header(width: contentWidth)
                                recorderPanel(width: contentWidth)

                                RecordingListView(
                                    recordings: $viewModel.recordings,
                                    rename: viewModel.rename,
                                    delete: viewModel.delete
                                )
                                .frame(minHeight: viewModel.recordings.isEmpty ? 250 : 360)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, sidePadding)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Voice R+")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Recording.self) { recording in
                PlaybackView(
                    recording: recording,
                    onRename: viewModel.rename,
                    onDelete: viewModel.delete
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.refreshRecordings()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh recordings")
                }
            }
            .task {
                await viewModel.requestPermission()
            }
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private func header(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Label("Local recorder", systemImage: "waveform.badge.mic")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())

                Spacer(minLength: 8)

                Label("\(viewModel.recordings.count)", systemImage: "doc.text")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.ultraThinMaterial, in: Capsule())
            }

            Text("Voice R+")
                .font(.system(size: titleFontSize(for: width), weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Record clearly. Play back anytime.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 12)
    }

    private func recorderPanel(width: CGFloat) -> some View {
        let compact = width < 360

        return VStack(spacing: compact ? 16 : 22) {
            VStack(spacing: 10) {
                Label(statusText, systemImage: statusSymbol)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(statusColor)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(statusColor.opacity(0.12), in: Capsule())

                Text(TimeFormatter.duration(viewModel.currentTime))
                    .font(.system(size: timerFontSize(for: width), weight: .semibold, design: .rounded).monospacedDigit())
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            waveform
                .frame(height: compact ? 112 : 132)

            RecordButtonView(
                isRecording: viewModel.isRecording,
                isPaused: viewModel.isPaused,
                action: primaryRecordAction
            )

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    pauseResumeButton
                    stopSaveButton
                }

                VStack(spacing: 10) {
                    pauseResumeButton
                    stopSaveButton
                }
            }
        }
        .padding(panelPadding(for: width))
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(.white.opacity(0.44), lineWidth: 1)
        }
        .shadow(color: Color.blue.opacity(0.10), radius: 28, y: 16)
        .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
    }

    private var waveform: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground).opacity(0.72))

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.44), lineWidth: 1)

            if !viewModel.isRecording {
                VStack(spacing: 10) {
                    Image(systemName: "waveform")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text("Ready to capture audio")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 12)
            }

            GeometryReader { proxy in
                let spacing: CGFloat = 4
                let horizontalInset: CGFloat = 16
                let availableWidth = max(0, proxy.size.width - horizontalInset * 2)
                let barCount = max(24, min(42, Int(availableWidth / 9)))
                let barWidth = max(3, min(5, (availableWidth - CGFloat(barCount - 1) * spacing) / CGFloat(barCount)))

                HStack(alignment: .center, spacing: spacing) {
                    ForEach(0..<barCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(waveformColor(index: index, count: barCount))
                            .frame(width: barWidth, height: barHeight(index: index, count: barCount))
                            .opacity(viewModel.isRecording ? 1 : 0.22)
                            .animation(.spring(response: 0.20, dampingFraction: 0.66), value: viewModel.audioLevel)
                            .animation(.linear(duration: 0.05), value: viewModel.currentTime)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, horizontalInset)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var pauseResumeButton: some View {
        Button {
            viewModel.isPaused ? viewModel.resumeRecording() : viewModel.pauseRecording()
        } label: {
            Label(viewModel.isPaused ? "Resume" : "Pause", systemImage: viewModel.isPaused ? "play.fill" : "pause.fill")
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(!viewModel.isRecording)
    }

    private var stopSaveButton: some View {
        Button(role: .destructive) {
            viewModel.stopAndSaveRecording()
        } label: {
            Label("Stop and Save", systemImage: "stop.fill")
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.isRecording)
    }

    private var statusText: String {
        if viewModel.isRecording && viewModel.isPaused { return "Paused" }
        if viewModel.isRecording { return "Recording" }
        return "Ready"
    }

    private var statusSymbol: String {
        if viewModel.isRecording && viewModel.isPaused { return "pause.circle.fill" }
        if viewModel.isRecording { return "record.circle.fill" }
        return "mic.circle.fill"
    }

    private var statusColor: Color {
        if viewModel.isRecording && viewModel.isPaused { return .orange }
        if viewModel.isRecording { return .red }
        return .blue
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }

    private func primaryRecordAction() {
        if viewModel.isRecording {
            viewModel.isPaused ? viewModel.resumeRecording() : viewModel.pauseRecording()
        } else {
            viewModel.startRecording()
        }
    }

    private func horizontalPadding(for width: CGFloat) -> CGFloat {
        width < 390 ? 16 : 20
    }

    private func titleFontSize(for width: CGFloat) -> CGFloat {
        min(max(width * 0.078, 28), 34)
    }

    private func timerFontSize(for width: CGFloat) -> CGFloat {
        min(max(width * 0.15, 52), 64)
    }

    private func panelPadding(for width: CGFloat) -> CGFloat {
        width < 360 ? 16 : 22
    }

    private func barHeight(index: Int, count: Int) -> CGFloat {
        guard viewModel.isRecording else {
            return CGFloat(12 + abs(sin(Double(index) * 0.55)) * 24)
        }

        if viewModel.isPaused {
            return CGFloat(14 + abs(sin(Double(index) * 0.5)) * 18)
        }

        let center = Double(max(count - 1, 1)) / 2
        let distanceFromCenter = abs(Double(index) - center) / center
        let envelope = 1.0 - min(0.55, distanceFromCenter * 0.55)
        let wave = abs(sin(Double(index) * 0.48 + viewModel.currentTime * 8.5))
        let secondaryWave = abs(cos(Double(index) * 0.23 + viewModel.currentTime * 5.5))
        let level = max(0.18, Double(viewModel.audioLevel))
        return CGFloat(12 + (wave * 68 + secondaryWave * 24) * level * envelope)
    }

    private func waveformColor(index: Int, count: Int) -> LinearGradient {
        let isRightSide = index > count / 2
        return LinearGradient(
            colors: viewModel.isRecording
                ? (isRightSide ? [.purple, .blue] : [.blue, .cyan])
                : [Color.secondary.opacity(0.42), Color.secondary.opacity(0.22)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    HomeView()
}
