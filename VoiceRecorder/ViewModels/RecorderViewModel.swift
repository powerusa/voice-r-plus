import AVFoundation
import Foundation
import SwiftUI

@MainActor
final class RecorderViewModel: ObservableObject {
    enum PermissionState {
        case unknown
        case granted
        case denied
    }

    @Published var recordings: [Recording] = []
    @Published var permissionState: PermissionState = .unknown
    @Published var errorMessage: String?

    @Published private(set) var isRecording = false
    @Published private(set) var isPaused = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var audioLevel: CGFloat = 0

    private let recorderService: AudioRecorderService
    private let storageService: RecordingStorageService
    private var observationTask: Task<Void, Never>?

    init(
        recorderService: AudioRecorderService = AudioRecorderService(),
        storageService: RecordingStorageService = .shared
    ) {
        self.recorderService = recorderService
        self.storageService = storageService
        recordings = storageService.loadRecordings()
        observeRecorder()
        refreshPermissionState()
    }

    deinit {
        observationTask?.cancel()
    }

    func refreshPermissionState() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            permissionState = .granted
        case .denied:
            permissionState = .denied
        default:
            permissionState = .unknown
        }
    }

    func requestPermission() async {
        let granted = await recorderService.requestPermission()
        permissionState = granted ? .granted : .denied
    }

    func startRecording() {
        guard permissionState == .granted else {
            Task { await requestPermission() }
            return
        }

        do {
            let url = try storageService.makeRecordingURL()
            try recorderService.startRecording(to: url)
            errorMessage = nil
        } catch {
            errorMessage = "Could not start recording. Please try again."
        }
    }

    func pauseRecording() {
        recorderService.pauseRecording()
    }

    func resumeRecording() {
        recorderService.resumeRecording()
    }

    func stopAndSaveRecording() {
        do {
            guard let url = try recorderService.stopRecording() else { return }
            let duration = try audioDuration(for: url)

            if duration < 0.5 {
                try? FileManager.default.removeItem(at: url)
                return
            }

            let recording = Recording(
                name: TimeFormatter.defaultRecordingName(),
                fileURL: url,
                duration: duration
            )

            recordings = try storageService.addRecording(recording, to: recordings)
            errorMessage = nil
        } catch {
            errorMessage = "Could not save recording."
        }
    }

    func rename(_ recording: Recording, to newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        var updatedRecording = recording
        updatedRecording.name = trimmedName

        do {
            recordings = try storageService.updateRecording(updatedRecording, in: recordings)
        } catch {
            errorMessage = "Could not rename recording."
        }
    }

    func delete(_ recording: Recording) {
        do {
            recordings = try storageService.deleteRecording(recording, from: recordings)
        } catch {
            errorMessage = "Could not delete recording."
        }
    }

    func refreshRecordings() {
        recordings = storageService.loadRecordings()
    }

    private func observeRecorder() {
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await _ in Timer.publish(every: 0.05, on: .main, in: .common).autoconnect().values {
                self.isRecording = self.recorderService.isRecording
                self.isPaused = self.recorderService.isPaused
                self.currentTime = self.recorderService.currentTime
                self.audioLevel = self.recorderService.audioLevel
            }
        }
    }

    private func audioDuration(for url: URL) throws -> TimeInterval {
        try AVAudioPlayer(contentsOf: url).duration
    }
}
