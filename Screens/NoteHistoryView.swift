//
//  NoteHistoryView.swift
//  NoteBot
//
//  Created by Theo Koester on 9/23/24.
//

import SwiftUI



struct NoteHistoryView: View {
    @StateObject private var viewModel = NoteHistoryViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.callDetails) { callDetail in
                NoteHistoryListItem(callDetail: callDetail)
                    .onTapGesture {
                        viewModel.handleCallDetailSelection(callDetail)
                    }
            }
            .navigationTitle("") // Clear default title
            .navigationBarTitleDisplayMode(.inline) // Use inline title for custom placement
            .toolbar {
                ToolbarItem(placement: .principal) { // Center the title
                    Text("Note History")
                        .font(.headline)
                        .foregroundColor(.primary) // Adjust color if needed
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
            .sheet(item: $viewModel.selectedCallDetail) { callDetail in
                NoteView(callDetail: callDetail)
            }
        }
    }
}


struct NoteHistoryListItem: View {
    let callDetail: CallDetails

    var body: some View {
        HStack {
            
            callDetail.icon
                .foregroundColor(.accentColor)
                .font(.system(size: 32))
    
            
            VStack(alignment: .leading) {
                Text(callDetail.title ?? "Untitled")
                    .font(.headline)
                Text(callDetail.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(callDetail.callType ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity) // Ensure text stays on the left
        }

    }
}





#Preview {
    NoteHistoryView()
}
