//
//  ProfileViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/5/25.
//

import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isEditing = false
    @Published var editedFullName = ""
    @Published var editedEmail = ""
    @Published var editedPhoneNumber = ""
    @Published var showingLogoutAlert = false
    
    private let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager = .shared) {
        self.authManager = authManager
        self.currentUser = authManager.currentUser
    }
    
    func fetchUserProfile() async {
        isLoading = true
        do {
            try await authManager.fetchUserProfile()
            currentUser = authManager.currentUser
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func startEditing() {
        if let user = currentUser {
            editedFullName = user.fullName
            editedEmail = user.email
            editedPhoneNumber = user.phoneNumber ?? ""
            isEditing = true
        }
    }
    
    func saveChanges() async {
        do {
            try await authManager.updateProfile(
                fullName: editedFullName,
                email: editedEmail,
                phoneNumber: editedPhoneNumber
            )
            isEditing = false
            await fetchUserProfile()  // Refresh the profile
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func logout() async {
        do {
            try await authManager.logout()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
