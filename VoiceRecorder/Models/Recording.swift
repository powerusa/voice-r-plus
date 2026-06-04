import Foundation

struct Recording: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var fileURL: URL
    var createdAt: Date
    var duration: TimeInterval

    init(
        id: UUID = UUID(),
        name: String,
        fileURL: URL,
        createdAt: Date = Date(),
        duration: TimeInterval
    ) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.createdAt = createdAt
        self.duration = duration
    }
}

extension Recording {
    static let preview = Recording(
        name: "Team Sync",
        fileURL: URL(fileURLWithPath: "/tmp/team-sync.m4a"),
        createdAt: .now,
        duration: 184
    )
}
