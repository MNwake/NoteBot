//
//  NoteView.swift
//  NoteBot
//
//  Created by Theo Koester on 9/23/24.
//

import SwiftUI
struct NoteView: View {
    @StateObject private var viewModel: NoteViewModel
    
    init(callDetail: CallDetails) {
        _viewModel = StateObject(wrappedValue: NoteViewModel(callDetail: callDetail))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Title
                Text(viewModel.callDetail.title ?? "Untitled")
                    .font(.largeTitle)
                    .padding(.bottom, 5)
                
                // Date
                Text("Date: \(viewModel.callDetail.date, style: .date) at \(viewModel.callDetail.date, style: .time)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Audio Type
                Text("Audio Type: \(viewModel.callDetail.callType ?? "Unknown")")
                    .font(.headline)
                
                // Participants
                if !viewModel.callDetail.participants.isEmpty {
                    Text("Participants:")
                        .font(.headline)
                        .padding(.top, 10)
                    ForEach(viewModel.callDetail.participants, id: \.id) { participant in
                        VStack(alignment: .leading) {
                            Text("Name: \(participant.name)")
                                .font(.subheadline)
                            Text("Role: \(participant.role)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if participant.isHost {
                                Text("Host")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            if !participant.additionalNotes.isEmpty {
                                Text("Notes: \(participant.additionalNotes)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // Notes
                if !viewModel.callDetail.notes.isEmpty {
                    Text("Notes:")
                        .font(.headline)
                        .padding(.top, 10)
                    Text(viewModel.callDetail.notes)
                        .font(.body)
                        .padding(.top, 5)
                }
                
                // Note Type Responses (Expandable)
                if let noteTypeResponses = viewModel.callDetail.noteTypeResponse, !noteTypeResponses.isEmpty {
                    Text("Note Type Responses:")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    ForEach(noteTypeResponses.keys.sorted(), id: \.self) { key in
                        if let response = noteTypeResponses[key] {
                            DisclosureGroup(isExpanded: Binding(
                                get: { viewModel.isNoteTypeExpanded[key] ?? false },
                                set: { viewModel.isNoteTypeExpanded[key] = $0 }
                            )) {
                                VStack(alignment: .leading) {
                                    switch response {
                                    case .string(let singleResponse):
                                        Text(singleResponse)
                                            .padding(.top, 2)
                                    
                                    case .array(let multipleResponses):
                                        ForEach(multipleResponses, id: \.self) { item in
                                            Text(item)
                                                .padding(.top, 2)
                                        }
                                    }
                                }
                            } label: {
                                Text(key.capitalized)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                // Transcription (Expandable)
                if let transcription = viewModel.callDetail.transcription,
                   let utterances = transcription.utterances,
                   !utterances.isEmpty {
                    DisclosureGroup(isExpanded: $viewModel.isTranscriptionExpanded) {
                        VStack(alignment: .leading) {
                            ForEach(utterances, id: \.id) { utterance in
                                Text("\(utterance.speaker): \"\(utterance.text)\"")
                                    .padding(.vertical, 2)
                                    .textSelection(.enabled)
                            }
                        }
                    } label: {
                        Text("Transcription")
                            .font(.headline)
                    }
                    .padding(.vertical, 5)
                } else if viewModel.callDetail.transcription != nil {
                    Text("No speech detected in recording")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 5)
                }
                
                // Token Usage
                if let tokenUsage = viewModel.callDetail.tokenUsage {
                    Text("Token Usage:")
                        .font(.headline)
                        .padding(.top, 10)
                    VStack(alignment: .leading) {
                        Text("Transcription Cost: $\(tokenUsage.transcriptionCost, specifier: "%.4f")")
                            .font(.subheadline)
                        Text("Input Cost: $\(tokenUsage.inputCost, specifier: "%.4f")")
                            .font(.subheadline)
                        Text("Output Cost: $\(tokenUsage.outputCost, specifier: "%.4f")")
                            .font(.subheadline)
                        Text("Total Cost: $\(tokenUsage.totalCost, specifier: "%.4f")")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Note Details")
        .onAppear {
            print("Call Details: \(viewModel.callDetail)")
            print("Note Type Responses: \(viewModel.callDetail.noteTypeResponse ?? [:])")
        }
    }
}
