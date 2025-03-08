//
//  PlaybackViewModel.swift
//  HR Notes
//
//  Created by Theo Koester on 9/16/24.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class PlaybackViewModel: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var playbackProgress: Double = 0.0
    @Published var playbackTime: String = "00:00"
    @Published var errorMessage: String?
    @Published var soundSamples: [Float] = Array(repeating: -50, count: 10)
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private let onDelete: () async -> Void
    private let sendRecordingAction: () async -> Void
    
    init(audioFile: URL, onDelete: @escaping () async -> Void, sendRecordingAction: @escaping () async -> Void) {
        self.onDelete = onDelete
        self.sendRecordingAction = sendRecordingAction
        self.soundSamples = Array(repeating: -50, count: 10) // Initialize with default values
        super.init()
        prepareAudio(file: audioFile)
    }
    
    private func prepareAudio(file: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: file)
            audioPlayer?.delegate = self
        } catch {
            print("Error preparing audio player: \(error)")
        }
    }

    func playAudio() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }

    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }

    func deleteRecording() async {
        do {
            if let url = audioPlayer?.url {
                try FileManager.default.removeItem(at: url)
                await onDelete()
            }
        } catch {
            errorMessage = "Failed to delete audio file: \(error.localizedDescription)"
        }
    }

    func handleSendRecording() async {
        await sendRecordingAction()
    }

    // Update progress and time while playing
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = self.audioPlayer {
                self.playbackProgress = player.currentTime / player.duration
                self.playbackTime = self.formatTime(player.currentTime)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Seek the audio to the selected progress
    func seekAudio(to progress: Double) {
        if let player = audioPlayer {
            let newTime = progress * player.duration
            player.currentTime = newTime
            playbackProgress = progress
        }
    }
}

extension PlaybackViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopTimer()
        playbackProgress = 0.0
        playbackTime = formatTime(0)
    }
}
