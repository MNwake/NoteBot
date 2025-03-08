//
//  RecordingDetailsCard.swift
//  NoteBot
//
//  Created by Theo Koester on 3/8/25.
//

import SwiftUI

struct RecordingDetailsCard: View {
    let callDetails: CallDetails
    var editAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Recording Details")
                    .font(.system(size: 32, weight: .bold))
                Spacer()
                Button(action: editAction) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "phone.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    Text(callDetails.callType ?? "General - Any")
                        .font(.system(size: 17))
                }
                
                HStack {
                    Image(systemName: "person.2.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    Text(callDetails.orderedParticipants.isEmpty ? "Not Set" : callDetails.orderedParticipants.map { $0.name }.joined(separator: ", "))
                        .font(.system(size: 17))
                }
                
                HStack {
                    Image(systemName: "doc.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    Text(callDetails.notetype.isEmpty ? "Not Set" : callDetails.notetype.joined(separator: ", "))
                        .font(.system(size: 17))
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(16)
    }
}
