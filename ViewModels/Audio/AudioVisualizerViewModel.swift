//
//  AudioVisualizerViewModel.swift
//  HR Notes
//
//  Created by Theo Koester on 9/16/24.
//

import Foundation
import AVFoundation

@MainActor
class AudioVisualizerViewModel: ObservableObject {
    @Published var soundSamples: [Float]
    private let numberOfSamples: Int
    
    init(numberOfSamples: Int = 10) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: -50.0, count: numberOfSamples)
    }
    
    func updateSample(_ value: Float) {
        soundSamples.removeFirst()
        soundSamples.append(value)
    }
}



