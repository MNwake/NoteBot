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
    
    private var timer: Timer?
    private var monitoringTimer: Timer?
    private var secondsElapsed = 0
    private var currentSample = 0
    private var audioRecorder: AVAudioRecorder?
    
    // Number of samples for sound visualization
    private let numberOfSamples: Int
    
    init(numberOfSamples: Int = 10) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: -168, count: numberOfSamples)
        
        // Initialize CallDetails with default values and a default participant
        self.callDetails = CallDetails(
            date: Date(),
            callType: "General - Any",
            notes: "",
            participants: [
                Participant(
                    name: "Anonymous",
                    role: "Unknown",
                    isHost: false,
                    additionalNotes: "N/A"
                )
            ],
            notetype: [],
            minutesElapsed: 0,
            title: "Untitled Recording",
            transcription: nil,
            tokenUsage: nil,
            noteTypeResponse: nil
        )
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
            
            // Keep metering enabled to track audio levels
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
                audioRecorder?.isMeteringEnabled = true // Enable metering to track audio levels
                audioRecorder?.record()
                
                startMonitoringAudioLevels() // Start monitoring the audio levels in real-time
            } catch {
                print("Failed to start recording: \(error.localizedDescription)")
            }
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    // Function to stop recording and send call details
    func stopRecording() {
        isRecording = false
        isPaused = false
        stopTimer()
        stopMonitoringAudioLevels()
        soundSamples = [Float](repeating: -168, count: numberOfSamples)
        audioRecorder?.stop()
        
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
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start monitoring the audio levels in real-time
    private func startMonitoringAudioLevels() {
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.audioRecorder?.updateMeters()
            let soundLevel = self.audioRecorder?.averagePower(forChannel: 0) ?? -80
            self.soundSamples[self.currentSample] = soundLevel
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        }
    }
    
    // Stop monitoring the audio levels
    private func stopMonitoringAudioLevels() {
        monitoringTimer?.invalidate()
    }
    
    // Function to send the call details and audio file to the backend
    func sendRecordingToBackend() async {
        guard let audioFileURL = audioFileURL else {
            errorMessage = "No audio file available to send."
            return
        }
        
        // Update call details with current recording information
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
        
        do {
            let response = try await NetworkManager.shared.sendCallDetailsToBackend(
                fileURL: audioFileURL,
                callDetails: callDetails
            )
            print("Call details sent successfully! Server response: \(response)")
        } catch let error as NetworkError where error == .unauthorized {
            // Handle unauthorized error
            AuthenticationManager.shared.clearAuthentication()
        } catch {
            errorMessage = error.localizedDescription
        }
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
                await self?.sendRecordingToBackend()
            }
        )
    }
}
