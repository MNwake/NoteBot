//
//  EditParticipantForm.swift
//  HR Notes
//
//  Created by Theo Koester on 9/14/24.
//

import SwiftUI




// Add/Edit Participant View
struct AddEditParticipantView: View {
    @Binding var participant: Participant?
    var saveAction: (Participant) -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var role = ""
    @State private var isHost = false
    @State private var additionalNotes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Participant Details")) {
                    TextField("Name", text: $name)
                    TextField("Role", text: $role)
                    Toggle(isOn: $isHost) {
                        Text("Host / Main Speaker / Leader")
                    }
                    TextField("Additional Notes", text: $additionalNotes)
                }
            }
            .navigationTitle(participant == nil ? "Add Participant" : "Edit Participant")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveParticipant()
                    }
                    .disabled(name.isEmpty || role.isEmpty) // Disable if essential fields are empty
                }
            }
            .onAppear {
                // If editing, pre-fill the fields
                if let participant = participant {
                    name = participant.name
                    role = participant.role
                    isHost = participant.isHost
                    additionalNotes = participant.additionalNotes
                }
            }
        }
    }

    // Save participant action
    private func saveParticipant() {
        let newParticipant = Participant(id: participant?.id ?? UUID(), name: name, role: role, isHost: isHost, additionalNotes: additionalNotes)
        saveAction(newParticipant)
        presentationMode.wrappedValue.dismiss()
    }
}
