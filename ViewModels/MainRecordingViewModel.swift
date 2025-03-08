//
//  MainRecordingViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/8/25.
//

import Foundation

@MainActor
class MainRecordingViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var searchText: String = ""
    @Published var isRecording: Bool = false
    @Published var recordingViewModel = AudioRecorderViewModel()
    
    init() {
        // Load initial recordings
        loadRecordings()
    }
    
    func loadRecordings() {
        // TODO: Load recordings from storage or network
        // This is a placeholder implementation
        recordings = []
    }
    
    var filteredRecordings: [Recording] {
        if searchText.isEmpty {
            return recordings
        }
        return recordings.filter { recording in
            recording.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func startNewRecording() {
        isRecording = true
        recordingViewModel.startRecording()
    }
    
    func stopRecording() {
        isRecording = false
        recordingViewModel.handleStopRecording()
        loadRecordings() // Refresh the recordings list
    }
}
