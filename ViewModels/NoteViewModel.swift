//
//  NoteViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/5/25.
//

import Foundation

@MainActor
class NoteViewModel: ObservableObject {
    let callDetail: CallDetails
    @Published var isNoteTypeExpanded: [String: Bool] = [:]
    @Published var isTranscriptionExpanded = false
    
    init(callDetail: CallDetails) {
        self.callDetail = callDetail
    }
    
    func toggleNoteTypeExpansion(for key: String) {
        isNoteTypeExpanded[key] = !(isNoteTypeExpanded[key] ?? false)
    }
    
    func toggleTranscriptionExpansion() {
        isTranscriptionExpanded.toggle()
    }
}
