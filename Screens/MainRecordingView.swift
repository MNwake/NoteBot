//
//  MainRecordingView.swift
//  NoteBot
//
//  Created by Theo Koester on 3/8/25.
//

import SwiftUI

struct MainRecordingView: View {
    @StateObject private var viewModel = MainRecordingViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Note History List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredRecordings) { recording in
                            RecordingListItem(recording: recording)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Recording Controls
                VStack {
                    if viewModel.isRecording {
                        // Recording View
                        VStack(spacing: 30) {
                            // Recording Details Card
                            RecordingDetailsCard(
                                callDetails: viewModel.recordingViewModel.callDetails,
                                editAction: { /* Handle edit action */ }
                            )
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            // Timer and Visualizer
                            VStack(spacing: 20) {
                                Text(viewModel.recordingViewModel.timerString)
                                    .font(.system(size: 60, weight: .thin, design: .monospaced))
                                
                                // Audio Visualizer
                                AudioVisualizerView(soundSamples: .constant(viewModel.recordingViewModel.soundSamples))
                                    .frame(height: 2)  // Make it a thin line
                                    .padding(.horizontal)
                            }
                            
                            Spacer()
                            
                            // Recording Controls
                            RecordingControlsView(
                                isRecording: $viewModel.recordingViewModel.isRecording,
                                isPaused: $viewModel.recordingViewModel.isPaused,
                                timerString: $viewModel.recordingViewModel.timerString,
                                soundSamples: viewModel.recordingViewModel.soundSamples,
                                startRecordingAction: viewModel.recordingViewModel.startRecording,
                                pauseRecordingAction: viewModel.recordingViewModel.pauseRecording,
                                resumeRecordingAction: viewModel.recordingViewModel.resumeRecording,
                                stopRecordingAction: viewModel.stopRecording
                            )
                        }
                        .background(Color(.systemBackground))
                    } else {
                        // Record Button
                        Button {
                            viewModel.startNewRecording()
                        } label: {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 65, height: 65)
                                .overlay(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                )
                        }
                        .padding(.bottom, 30)
                    }
                }
                .background(Color(.systemGroupedBackground))  // Light gray background
            }
        }
        .navigationTitle("All Recordings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Handle edit action
                }
                .foregroundColor(.blue)
            }
        }
    }
}

// Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Titles, Transcripts", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Recording List Item Component
struct RecordingListItem: View {
    let recording: Recording // You'll need to create this model
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recording.title)
                .font(.headline)
            HStack {
                Text(recording.date, style: .date)
                Spacer()
                Text(recording.duration)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            Divider()
        }
        .padding(.vertical, 8)
    }
}
