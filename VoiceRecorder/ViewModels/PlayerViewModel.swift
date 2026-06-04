import Foundation

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var recording: Recording
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var errorMessage: String?

    private let playerService: AudioPlayerService
    private var observationTask: Task<Void, Never>?

    init(recording: Recording, playerService: AudioPlayerService = AudioPlayerService()) {
        self.recording = recording
        self.playerService = playerService
        duration = recording.duration
        observePlayer()
        loadRecording()
    }

    deinit {
        observationTask?.cancel()
        playerService.stop()
    }

    func loadRecording() {
        do {
            try playerService.load(url: recording.fileURL)
            duration = playerService.duration
            errorMessage = nil
        } catch {
            errorMessage = "This recording file could not be found."
        }
    }

    func togglePlayback() {
        guard errorMessage == nil else { return }
        playerService.togglePlayback()
    }

    func seek(to time: TimeInterval) {
        playerService.seek(to: time)
    }

    func skipForward() {
        playerService.skip(by: 15)
    }

    func skipBackward() {
        playerService.skip(by: -15)
    }

    func stop() {
        playerService.stop()
    }

    private func observePlayer() {
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await _ in Timer.publish(every: 0.2, on: .main, in: .common).autoconnect().values {
                self.isPlaying = self.playerService.isPlaying
                self.currentTime = self.playerService.currentTime
                self.duration = self.playerService.duration
            }
        }
    }
}
