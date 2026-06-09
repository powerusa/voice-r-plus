import SwiftUI

struct RecordingListView: View {
    @Binding var recordings: [Recording]
    let rename: (Recording, String) -> Void
    let delete: (Recording) -> Void

    @State private var recordingToRename: Recording?
    @State private var renameText = ""

    var body: some View {
        Group {
            if recordings.isEmpty {
                ContentUnavailableView(
                    "No Recordings",
                    systemImage: "waveform.path.ecg",
                    description: Text("Voice logs will appear here.")
                )
                .foregroundStyle(.white.opacity(0.9), Color.cyan.opacity(0.68), Color.white.opacity(0.54))
                .frame(maxWidth: .infinity, minHeight: 220)
            } else {
                List {
                    ForEach(recordings) { recording in
                        NavigationLink(value: recording) {
                            RecordingRowView(recording: recording)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(recording)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                startRenaming(recording)
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .contextMenu {
                            Button {
                                startRenaming(recording)
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }

                            ShareLink(item: recording.fileURL) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }

                            Button(role: .destructive) {
                                delete(recording)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 92)
            }
        }
        .alert("Rename Recording", isPresented: renameAlertBinding) {
            TextField("Name", text: $renameText)
            Button("Cancel", role: .cancel) {
                recordingToRename = nil
            }
            Button("Save") {
                if let recordingToRename {
                    rename(recordingToRename, renameText)
                }
                recordingToRename = nil
            }
        }
    }

    private var renameAlertBinding: Binding<Bool> {
        Binding(
            get: { recordingToRename != nil },
            set: { isPresented in
                if !isPresented {
                    recordingToRename = nil
                }
            }
        )
    }

    private func startRenaming(_ recording: Recording) {
        recordingToRename = recording
        renameText = recording.name
    }
}

#Preview {
    NavigationStack {
        RecordingListView(
            recordings: .constant([.preview]),
            rename: { _, _ in },
            delete: { _ in }
        )
    }
}
