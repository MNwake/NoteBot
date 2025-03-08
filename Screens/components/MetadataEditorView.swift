//
//  MetadataEditorView.swift
//  NoteBot
//
//  Created by Theo Koester on 3/2/25.
//

import SwiftUI

struct MetadataEditorView: View {
    @Binding var callDetails: CallDetails
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    // Local state for managing different sections
    @State private var showCallTypeSheet = false
    @State private var showParticipantsSheet = false
    @State private var showNoteFormatSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // Call Type Section
                Section {
                    Button(action: { showCallTypeSheet.toggle() }) {
                        MetadataRowView(
                            icon: "phone.circle.fill",
                            title: "Audio Type",
                            value: callDetails.callType ?? "Not Set"
                        )
                    }
                }
                
                // Participants Section
                Section {
                    Button(action: { showParticipantsSheet.toggle() }) {
                        MetadataRowView(
                            icon: "person.2.circle.fill",
                            title: "Participants",
                            value: participantsPreview,
                            showChevron: true
                        )
                    }
                }
                
                // Note Format Section
                Section {
                    Button(action: { showNoteFormatSheet.toggle() }) {
                        MetadataRowView(
                            icon: "doc.text.fill",
                            title: "Note Format",
                            value: noteFormatPreview,
                            showChevron: true
                        )
                    }
                }
                
                // Additional Notes Section
                Section {
                    TextEditor(text: Binding(
                        get: { callDetails.notes },
                        set: { callDetails.notes = $0 }
                    ))
                    .frame(minHeight: 100)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                } header: {
                    Text("Additional Notes")
                } footer: {
                    Text("Add any extra context or notes about this recording")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Recording Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showCallTypeSheet) {
            EditCallTypeView(selectedCallType: Binding(
                get: { callDetails.callType ?? "" },
                set: { callDetails.callType = $0 }
            ))
        }
        .sheet(isPresented: $showParticipantsSheet) {
            EditParticipantsView(callDetails: $callDetails)
        }
        .sheet(isPresented: $showNoteFormatSheet) {
            EditNoteFormatView(selectedFormats: Binding(
                get: { callDetails.notetype },
                set: { callDetails.notetype = $0 }
            ))
        }
    }
    
    // Helper computed properties for previews
    private var participantsPreview: String {
        if callDetails.participants.isEmpty {
            return "No participants added"
        }
        return callDetails.participants
            .map { $0.name }
            .joined(separator: ", ")
    }
    
    private var noteFormatPreview: String {
        if callDetails.notetype.isEmpty {
            return "No format selected"
        }
        return callDetails.notetype.joined(separator: ", ")
    }
}
