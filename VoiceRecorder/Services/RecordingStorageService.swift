import Foundation

final class RecordingStorageService {
    static let shared = RecordingStorageService()

    private let fileManager: FileManager
    private let metadataFileName = "recordings.json"

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var metadataURL: URL {
        documentsDirectory.appendingPathComponent(metadataFileName)
    }

    func recordingsDirectory() throws -> URL {
        let directory = documentsDirectory.appendingPathComponent("Recordings", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    func makeRecordingURL() throws -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let fileName = "recording-\(formatter.string(from: .now))-\(UUID().uuidString.prefix(8)).m4a"
        return try recordingsDirectory().appendingPathComponent(fileName)
    }

    func loadRecordings() -> [Recording] {
        guard fileManager.fileExists(atPath: metadataURL.path) else { return [] }

        do {
            let data = try Data(contentsOf: metadataURL)
            let recordings = try JSONDecoder().decode([Recording].self, from: data)
            return recordings.filter { fileManager.fileExists(atPath: $0.fileURL.path) }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("Unable to load recordings: \(error)")
            return []
        }
    }

    func saveRecordings(_ recordings: [Recording]) throws {
        let data = try JSONEncoder().encode(recordings.sorted { $0.createdAt > $1.createdAt })
        try data.write(to: metadataURL, options: [.atomic])
    }

    func addRecording(_ recording: Recording, to recordings: [Recording]) throws -> [Recording] {
        var updated = recordings
        updated.insert(recording, at: 0)
        try saveRecordings(updated)
        return updated
    }

    func updateRecording(_ recording: Recording, in recordings: [Recording]) throws -> [Recording] {
        var updated = recordings
        guard let index = updated.firstIndex(where: { $0.id == recording.id }) else {
            return recordings
        }

        updated[index] = recording
        try saveRecordings(updated)
        return updated.sorted { $0.createdAt > $1.createdAt }
    }

    func deleteRecording(_ recording: Recording, from recordings: [Recording]) throws -> [Recording] {
        if fileManager.fileExists(atPath: recording.fileURL.path) {
            try fileManager.removeItem(at: recording.fileURL)
        }

        let updated = recordings.filter { $0.id != recording.id }
        try saveRecordings(updated)
        return updated
    }
}
