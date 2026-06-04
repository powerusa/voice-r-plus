import Foundation

enum TimeFormatter {
    static func duration(_ time: TimeInterval) -> String {
        let totalSeconds = max(0, Int(time.rounded()))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func date(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    static func defaultRecordingName(date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h.mm a"
        return "Recording \(formatter.string(from: date))"
    }
}
