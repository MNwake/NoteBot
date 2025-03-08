//
//  EditAttendeesView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/20/24.
//
import SwiftUI


// EditParticipantsView - A view to manage participants
struct EditParticipantsView: View {
    @Binding var callDetails: CallDetails // Bind callDetails directly to allow modifications
    
    @State private var showAddParticipantSheet = false
    @State private var editingParticipant: Participant? = nil

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(callDetails.participants) { participant in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(participant.name)
                                .font(.headline)
                            Text(participant.role)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if participant.isHost {
                                Text("Host / Main Speaker")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                            if !participant.additionalNotes.isEmpty {
                                Text("Notes: \(participant.additionalNotes)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteParticipant(participant)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                editingParticipant = participant
                                showAddParticipantSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                // Button to add new participants
                Button(action: {
                    editingParticipant = nil
                    showAddParticipantSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Participant")
                    }
                    .font(.headline)
                    .padding()
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Edit Participants")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddParticipantSheet) {
                AddEditParticipantView(
                    participant: $editingParticipant,
                    saveAction: saveParticipant
                )
            }
        }
    }

    // Delete participant function
    private func deleteParticipant(_ participant: Participant) {
        if let index = callDetails.participants.firstIndex(where: { $0.id == participant.id }) {
            callDetails.participants.remove(at: index)
            print("Updated CallDetails Participants: \(callDetails.participants)")
        }
    }

    // Save or update participant function
    private func saveParticipant(_ participant: Participant) {
        if let existingParticipant = editingParticipant, let index = callDetails.participants.firstIndex(where: { $0.id == existingParticipant.id }) {
            // Editing existing participant
            callDetails.participants[index] = participant
        } else {
            // Adding a new participant
            callDetails.participants.append(participant)
        }
        print("Updated CallDetails Participants: \(callDetails.participants)")
    }
}



