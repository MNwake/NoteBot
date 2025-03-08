//
//  AudioVisualizerView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/16/24.
//

import SwiftUI

let numberOfSamples: Int = 10

struct AudioVisualizerView: View {
    @Binding var soundSamples: [Float]
    
    var body: some View {
        TimelineWaveformView(samples: soundSamples)
            .frame(height: 50)
            .padding(.horizontal)
    }
}

struct BarView: View {
    var value: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [
                    Color.blue.opacity(0.7),
                    Color.blue.opacity(0.4)
                ]), startPoint: .top, endPoint: .bottom))
                .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 4) / CGFloat(numberOfSamples), height: value)
                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}


struct TimelineWaveformView: View {
    let samples: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midHeight = height / 2
                
                // Draw the waveform
                for (index, sample) in samples.enumerated() {
                    let x = width * CGFloat(index) / CGFloat(samples.count)
                    let normalizedSample = CGFloat(sample + 50) / 50 // Normalize to 0-1
                    let y = midHeight + (normalizedSample * midHeight)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}
