//
//  NoteHistoryViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 9/23/24.
//

import Foundation
import Combine

@MainActor
class NoteHistoryViewModel: ObservableObject {
    @Published var callDetails: [CallDetails] = []
    @Published var selectedCallDetail: CallDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchCallDetails() async {
        isLoading = true
        do {
            callDetails = try await NetworkManager.shared.getCallDetails()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func onAppear() {
        Task {
            await fetchCallDetails()
        }
    }
    
    func handleCallDetailSelection(_ callDetail: CallDetails) {
        selectedCallDetail = callDetail
    }
}
