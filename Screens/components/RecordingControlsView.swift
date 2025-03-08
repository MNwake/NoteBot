//
//  RecordingControlsView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/14/24.
//
import SwiftUI


struct RecordingControlsView: View {
    @Binding var isRecording: Bool
    @Binding var isPaused: Bool
    @Binding var timerString: String
    var soundSamples: [Float]
    var startRecordingAction: () -> Void
    var pauseRecordingAction: () -> Void
    var resumeRecordingAction: () -> Void
    var stopRecordingAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if isRecording {
                // Timer display
                Text(timerString)
                    .font(.system(size: 60, weight: .thin, design: .monospaced))
                    .foregroundColor(.primary)
                
                // Record/Pause Button
                Button(action: {
                    if isPaused {
                        resumeRecordingAction()
                    } else {
                        pauseRecordingAction()
                    }
                }) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 65, height: 65)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: isPaused ? 20 : 26, height: isPaused ? 20 : 26)
                        )
                }
                
                // Done Button
                Button(action: stopRecordingAction) {
                    Text("Done")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.blue)
                }
            } else {
                // Initial Record Button
                Button(action: startRecordingAction) {
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                        .background(Circle().fill(Color.red))
                        .frame(width: 65, height: 65)
                }
            }
        }
        .padding(.bottom, 30)
    }
}
