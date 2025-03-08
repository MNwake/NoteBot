//
//  RecordingViewModel.swift
//  HR Notes
//
//  Created by Theo Koester on 9/14/24.
//
import Foundation
import SwiftUI
import AVFoundation

@MainActor
class AudioRecorderViewModel: ObservableObject {
    @Published var callDetails: CallDetails // Manage all details through this property
    @Published var audioFileURL: URL? = nil
    // Participant management
    
    // Recording control
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var timerString = "00:00"
    @Published var soundSamples: [Float] // We will initialize this in the init method
    @Published var errorMessage: String?
    
    @Published var isPlaybackMode = false
    @Published var showMetadataSheet = false
    
    @Published var uploadStatus: String = ""
    @Published var documentId: String?
    
    @StateObject private var uploadStatusViewModel = AudioUploadStatusViewModel()
    
    private var timer: Timer?
    private var monitoringTimer: Timer?
    private var secondsElapsed = 0
    private var currentSample = 0
    private var audioRecorder: AVAudioRecorder?
    
    // Number of samples for sound visualization
    private let numberOfSamples: Int
    
    // Queue for managing recording uploads
    private var uploadQueue: [(URL, CallDetails)] = []
    private var isUploading = false
    
    init(numberOfSamples: Int = 10) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: -168, count: numberOfSamples)
        
        // Initialize CallDetails with default values and a default participant
        let defaultParticipant = Participant(
            name: "Anonymous",
            role: "Unknown",
            isHost: false,
            additionalNotes: "N/A"
        )
        
        // Create decoder for date handling
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        // Create the initial JSON data
        let initialJSON = """
        {
            "_cls": "CallDetails",
            "date": \(Date().timeIntervalSince1970),
            "callType": "General - Any",
            "notes": "",
            "participants": [{
                "name": "Anonymous",
                "role": "Unknown",
                "isHost": false,
                "additionalNotes": "N/A"
            }],
            "notetype": [],
            "minutes_elapsed": 0,
            "title": "Untitled Recording"
        }
        """.data(using: .utf8)!
        
        // Decode the initial JSON to create CallDetails
        do {
            self.callDetails = try decoder.decode(CallDetails.self, from: initialJSON)
        } catch {
            print("Error creating initial CallDetails: \(error)")
            // Fallback to empty CallDetails if decoding fails
            self.callDetails = try! decoder.decode(CallDetails.self, from: "{\"_cls\": \"CallDetails\"}".data(using: .utf8)!)
        }
    }
    
    // Function to start recording
    func startRecording() {
        print("start recording")
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            
            isRecording = true
            startTimer()
            
            let fileName = UUID().uuidString + ".m4a"
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            audioFileURL = documentDirectory.appendingPathComponent(fileName)
            
            // Updated settings for better compatibility
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
                audioRecorder?.isMeteringEnabled = true
                audioRecorder?.prepareToRecord()
                audioRecorder?.record()
                
                startMonitoringAudioLevels()
            } catch {
                print("Failed to start recording: \(error.localizedDescription)")
                errorMessage = "Failed to start recording: \(error.localizedDescription)"
            }
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            errorMessage = "Audio session setup failed: \(error.localizedDescription)"
        }
    }
    
    // Function to stop recording
    func stopRecording() {
        isRecording = false
        isPaused = false
        stopTimer()
        stopMonitoringAudioLevels()
        soundSamples = [Float](repeating: -168, count: numberOfSamples)
        
        // Ensure proper cleanup of audio recorder
        audioRecorder?.stop()
        
        // Add a longer delay to ensure the file is properly saved
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            if let url = audioFileURL {
                print("Audio file saved at: \(url.path)")
                print("File exists: \(FileManager.default.fileExists(atPath: url.path))")
                if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
                    let fileSize = attributes[.size] as? UInt64 ?? 0
                    print("File size after saving: \(fileSize) bytes")
                }
            }
        }
    }
    
    // Function to pause recording
    func pauseRecording() {
        isPaused = true
        audioRecorder?.pause()
        stopMonitoringAudioLevels()
        soundSamples = [Float](repeating: -168, count: numberOfSamples)
        stopTimer()
        print("Recording paused")
    }
    
    // Function to resume recording
    func resumeRecording() {
        guard isPaused else { return } // Ensure we only resume if paused
        isPaused = false
        isRecording = true
        audioRecorder?.record() // Resume recording from where it left off
        startMonitoringAudioLevels() // Start metering again
        startTimer() // Resume the timer
        print("Recording resumed")
    }
    
    // Timer functions to manage recording time
    private func startTimer() {
        print("Timer started")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.secondsElapsed += 1
                self.timerString = self.formatSeconds(self.secondsElapsed)
            }
        }
    }
    
    func stopTimer() {
        print("Timer stopped")
        timer?.invalidate()
    }
    
    func resetTimer() {
        print("Timer reset")
        secondsElapsed = 0
        timerString = "00:00"
        stopTimer()
    }
    
    private func formatSeconds(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        let milliseconds = Int((Double(seconds) - floor(Double(seconds))) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    // Start monitoring the audio levels in real-time
    private func startMonitoringAudioLevels() {
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.audioRecorder?.updateMeters()
                let soundLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? -80
                self.soundSamples[self.currentSample] = soundLevel
                self.currentSample = (self.currentSample + 1) % self.numberOfSamples
            }
        }
    }
    
    // Stop monitoring the audio levels
    private func stopMonitoringAudioLevels() {
        monitoringTimer?.invalidate()
    }
    
    // Function to add recording to queue and start processing
    func queueRecordingForUpload() {
        guard let audioFileURL = audioFileURL else {
            errorMessage = "No audio file available to send."
            return
        }
        
        // Validate the audio file
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: audioFileURL.path)
            let fileSize = fileAttributes[.size] as? UInt64 ?? 0
            
            guard fileSize > 0 else {
                errorMessage = "Audio file is empty"
                return
            }
            
            // Ensure callType is set
            if callDetails.callType == nil {
                callDetails.callType = "General - Any"
            }
            
            // Update call details
            callDetails.minutesElapsed = Double(secondsElapsed) / 60.0
            callDetails.date = Date()
            
            // Ensure there's at least one participant
            if callDetails.participants.isEmpty {
                callDetails.participants = [
                    Participant(
                        name: "Anonymous",
                        role: "Unknown",
                        isHost: false,
                        additionalNotes: "N/A"
                    )
                ]
            }
            
            // Add to queue
            uploadQueue.append((audioFileURL, callDetails))
            
            // Start processing queue if not already processing
            if !isUploading {
                Task {
                    await processUploadQueue()
                }
            }
        } catch {
            errorMessage = "Failed to validate audio file: \(error.localizedDescription)"
        }
    }
    
    // Process the upload queue
    private func processUploadQueue() async {
        isUploading = true
        
        while !uploadQueue.isEmpty {
            let (audioFileURL, callDetails) = uploadQueue.removeFirst()
            
            do {
                let response = try await NetworkManager.shared.sendCallDetailsToBackend(
                    fileURL: audioFileURL,
                    callDetails: callDetails
                )
                
                await MainActor.run {
                    // Add to status tracking
                    uploadStatusViewModel.addUpload(
                        documentId: response.documentId,
                        fileName: audioFileURL.lastPathComponent
                    )
                    self.errorMessage = nil
                }
                
                // Clean up the audio file
                try? FileManager.default.removeItem(at: audioFileURL)
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to send recording: \(error.localizedDescription)"
                }
                break
            }
        }
        
        await MainActor.run {
            self.isUploading = false
        }
    }
    
    private func uploadSuccess() {
        showSuccessMessage()
    }
    
    private func showSuccessMessage() {
        // You can implement this to show a success message to the user
        errorMessage = "Upload Success"// For example, using a temporary message that disappears after a few seconds
//        errorMessage = nil  // Clear any existing error message
        // Optionally show a success message or trigger UI feedback
    }
    
    // Update the existing sendRecordingToBackend to use the queue
    func sendRecordingToBackend() async {
        queueRecordingForUpload()
    }
    
    func handleStopRecording() {
        stopRecording()
        isPlaybackMode = true
    }
    
    func toggleMetadataSheet() {
        showMetadataSheet.toggle()
    }
    
    func createPlaybackViewModel() -> PlaybackViewModel? {
        guard let audioFileURL = audioFileURL else { return nil }
        return PlaybackViewModel(
            audioFile: audioFileURL,
            onDelete: { [weak self] in
                self?.isPlaybackMode = false
                self?.audioFileURL = nil
                self?.resetTimer()
            },
            sendRecordingAction: { [weak self] in
                if let self = self {
                    await self.sendRecordingToBackend()
                }
            }
        )
    }
}
