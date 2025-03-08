//
//  AudioRecordingView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/18/24.
//

import SwiftUI

struct AudioRecordingView: View {
    @StateObject var viewModel = AudioRecorderViewModel()
    @State private var isPlaybackMode = false
    @State private var showMetadataSheet = false
    @State private var playbackTime: String = "00:00"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Card with Recording Details
                VStack(spacing: 12) {
                    HStack {
                        Text("Recording Details")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: { showMetadataSheet.toggle() }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        // Call Type
                        HStack {
                            Image(systemName: "phone.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text(viewModel.callDetails.callType ?? "General - Any")
                                .font(.body)
                            Spacer()
                        }
                        
                        // Participants
                        HStack {
                            Image(systemName: "person.2.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text(viewModel.callDetails.orderedParticipants.isEmpty ? "Not Set" :
                                    viewModel.callDetails.orderedParticipants.map { $0.name }.joined(separator: ", "))
                                .font(.body)
                            Spacer()
                        }
                        
                        // Format
                        HStack {
                            Image(systemName: "doc.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text(viewModel.callDetails.notetype.isEmpty ? "Not Set" :
                                    viewModel.callDetails.notetype.joined(separator: ", "))
                                .font(.body)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding()
                
                Spacer()
                
                // Timer Display
                Text(isPlaybackMode ? playbackTime : viewModel.timerString)
                    .font(.system(size: 64, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .padding(.vertical, 30)
                
                // Audio Visualizer (only show during recording)
                if !isPlaybackMode {
                    AudioVisualizerView(soundSamples: .constant(viewModel.soundSamples))
                        .frame(height: 60)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Add error message display
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                        .padding()
                }
                
                // Recording/Playback Controls
                Group {
                    if viewModel.isPlaybackMode {
                        if let playbackViewModel = viewModel.createPlaybackViewModel() {
                            PlaybackView(viewModel: playbackViewModel)
                        }
                    } else {
                        RecordingControlsView(isRecording: $viewModel.isRecording,
                                            isPaused: $viewModel.isPaused,
                                            timerString: $viewModel.timerString,
                                            soundSamples: viewModel.soundSamples,
                                            startRecordingAction: viewModel.startRecording,
                                            pauseRecordingAction: viewModel.pauseRecording,
                                            resumeRecordingAction: viewModel.resumeRecording,
                                            stopRecordingAction: viewModel.handleStopRecording)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NoteHistoryView()) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showMetadataSheet) {
            MetadataEditorView(callDetails: $viewModel.callDetails)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}


