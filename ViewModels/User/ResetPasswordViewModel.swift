//
//  ResetPasswordViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/5/25.
//

import Foundation
import SwiftUI

class ResetPasswordViewModel: ObservableObject {
    @Published var verificationCode = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var message = ""
    @Published var isLoading = false
    @Published var isVerified = false
    @Published var showingPasswordFields = false
    
    let email: String
    private let authManager: AuthenticationManager
    
    init(email: String, authManager: AuthenticationManager = .shared) {
        self.email = email
        self.authManager = authManager
    }
    
    @MainActor
    func verifyCode() async {
        guard !verificationCode.isEmpty else {
            message = "Please enter the verification code"
            return
        }
        
        isLoading = true
        message = ""
        
        do {
            try await NetworkManager.shared.verifyPasswordResetCode(code: verificationCode)
            withAnimation {
                showingPasswordFields = true
                isLoading = false
            }
        } catch {
            isLoading = false
            // Check for specific error messages from the backend
            if error.localizedDescription.contains("Invalid") || 
               error.localizedDescription.contains("Expired") {
                message = "Invalid or expired verification code. Please try again."
            } else {
                message = "Failed to verify code. Please try again."
            }
            verificationCode = "" // Clear the invalid code
        }
    }
    
    @MainActor
    func resetPassword() async {
        guard !newPassword.isEmpty else {
            message = "Please enter a new password"
            return
        }
        
        guard newPassword == confirmPassword else {
            message = "Passwords do not match"
            return
        }
        
        isLoading = true
        message = ""
        
        do {
            let response = try await NetworkManager.shared.resetPassword(
                code: verificationCode,
                newPassword: newPassword
            )
            isLoading = false
            message = response
            isVerified = true
        } catch {
            isLoading = false
            message = error.localizedDescription
        }
    }
    
    @MainActor
    func resendCode() async {
        do {
            let response = try await NetworkManager.shared.requestPasswordReset(email: email)
            message = response
        } catch {
            message = error.localizedDescription
        }
    }
}
