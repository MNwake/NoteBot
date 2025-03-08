//
//  PlaybackView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/16/24.
//

import SwiftUI

struct PlaybackView: View {
    @ObservedObject var viewModel: PlaybackViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Waveform timeline visualization
            TimelineWaveformView(samples: viewModel.soundSamples)
                .frame(height: 50)
                .padding(.horizontal)
            
            // Playback controls in horizontal layout
            HStack(spacing: 40) {
                Button {
                    Task {
                        await viewModel.deleteRecording()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }

                if viewModel.isPlaying {
                    Button(action: viewModel.pauseAudio) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                } else {
                    Button(action: viewModel.playAudio) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                }

                Button {
                    Task {
                        await viewModel.handleSendRecording()
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

