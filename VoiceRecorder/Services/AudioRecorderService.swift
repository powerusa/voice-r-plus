import AVFoundation
import Foundation

final class AudioRecorderService: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var isPaused = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var audioLevel: CGFloat = 0

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    var currentURL: URL? {
        audioRecorder?.url
    }

    var permissionGranted: Bool {
        AVAudioApplication.shared.recordPermission == .granted
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func prepareSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
        try session.setPreferredSampleRate(48_000)
        try session.setPreferredIOBufferDuration(0.005)
        try session.setActive(true)
    }

    func startRecording(to url: URL) throws {
        try prepareSession()

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48_000,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 192_000,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.delegate = self
        recorder.isMeteringEnabled = true
        recorder.record()

        audioRecorder = recorder
        isRecording = true
        isPaused = false
        currentTime = 0
        startTimer()
    }

    func pauseRecording() {
        guard isRecording, !isPaused else { return }
        audioRecorder?.pause()
        isPaused = true
    }

    func resumeRecording() {
        guard isRecording, isPaused else { return }
        audioRecorder?.record()
        isPaused = false
    }

    func stopRecording() throws -> URL? {
        let url = audioRecorder?.url
        audioRecorder?.stop()
        audioRecorder = nil
        timer?.invalidate()
        timer = nil
        isRecording = false
        isPaused = false
        audioLevel = 0

        try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return url
    }

    func reset() {
        audioRecorder?.stop()
        audioRecorder = nil
        timer?.invalidate()
        timer = nil
        isRecording = false
        isPaused = false
        currentTime = 0
        audioLevel = 0
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            self.currentTime = recorder.currentTime

            let power = recorder.averagePower(forChannel: 0)
            let normalizedLevel = max(0, min(1, (power + 55) / 55))
            self.audioLevel = CGFloat(normalizedLevel)
        }
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Recorder error: \(error?.localizedDescription ?? "Unknown error")")
        reset()
    }
}
