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
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                Label("Local recorder", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.caption.monospaced().weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.cyan.opacity(0.86))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.black.opacity(0.28), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.cyan.opacity(0.24), lineWidth: 1)
                    }

                Spacer(minLength: 8)

                Label("\(viewModel.recordings.count)", systemImage: "doc.text")
                    .font(.caption.monospaced().weight(.semibold))
                    .foregroundStyle(Color.orange.opacity(0.88))
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.black.opacity(0.28), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.orange.opacity(0.24), lineWidth: 1)
                    }
            }

            Text("Voice R+")
                .font(.system(size: titleFontSize(for: width), weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Capture clear voice logs. Play back anytime.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.white.opacity(0.64))
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
                    .font(.subheadline.monospaced().weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(statusColor)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(statusColor.opacity(0.13), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(statusColor.opacity(0.32), lineWidth: 1)
                    }

                Text(TimeFormatter.duration(viewModel.currentTime))
                    .font(.system(size: timerFontSize(for: width), weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
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
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.105),
                    Color.black.opacity(0.34)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.cyan.opacity(0.48),
                            Color.white.opacity(0.12),
                            Color.orange.opacity(0.34)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.cyan.opacity(0.10), radius: 28, y: 16)
        .shadow(color: .black.opacity(0.34), radius: 18, y: 10)
    }

    private var waveform: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.34))

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.cyan.opacity(0.22), lineWidth: 1)

            HStack(spacing: 7) {
                ForEach(0..<5, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(0.045))
                        .frame(width: 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if !viewModel.isRecording {
                VStack(spacing: 10) {
                    Image(systemName: "waveform")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.cyan.opacity(0.62))

                    Text("Audio channel standing by")
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.54))
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
                .font(.headline.monospaced())
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.cyan.opacity(0.72))
        .controlSize(.large)
        .disabled(!viewModel.isRecording)
    }

    private var stopSaveButton: some View {
        Button(role: .destructive) {
            viewModel.stopAndSaveRecording()
        } label: {
            Label("Stop and Save", systemImage: "stop.fill")
                .font(.headline.monospaced())
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.orange)
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
        return .cyan
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
                ? (isRightSide ? [.orange, .red] : [.cyan, .blue])
                : [Color.cyan.opacity(0.32), Color.white.opacity(0.14)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    HomeView()
}
