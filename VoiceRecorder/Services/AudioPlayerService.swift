import AVFoundation
import Foundation

final class AudioPlayerService: NSObject, ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    func load(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CocoaError(.fileNoSuchFile)
        }

        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        let player = try AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.prepareToPlay()

        audioPlayer = player
        currentTime = 0
        duration = player.duration
    }

    func play() {
        guard let audioPlayer else { return }
        audioPlayer.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    func togglePlayback() {
        isPlaying ? pause() : play()
    }

    func seek(to time: TimeInterval) {
        guard let audioPlayer else { return }
        let newTime = min(max(0, time), audioPlayer.duration)
        audioPlayer.currentTime = newTime
        currentTime = newTime
    }

    func skip(by seconds: TimeInterval) {
        seek(to: currentTime + seconds)
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        timer?.invalidate()
        timer = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self, let audioPlayer = self.audioPlayer else { return }
            self.currentTime = audioPlayer.currentTime
            self.duration = audioPlayer.duration
            self.isPlaying = audioPlayer.isPlaying
        }
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        player.currentTime = 0
        timer?.invalidate()
        timer = nil
    }
}
