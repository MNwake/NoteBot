//
//  AudioUploadView.swift
//  NoteBot
//
//  Created by Theo Koester on 3/6/25.
//

import SwiftUI


struct AudioUploadStatusView: View {
    let status: String
    let documentId: String?
    
    var body: some View {
        VStack(spacing: 10) {
            if !status.isEmpty {
                Text("Status: \(status)")
                    .foregroundColor(.secondary)
            }
            
            if let docId = documentId {
                Text("Document ID: \(docId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
