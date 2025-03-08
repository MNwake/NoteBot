//
//  LoginViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/5/25.
//

import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var loginMessage = ""
    @Published var isLoading = false
    @Published var showPasswordField = false
    @Published var showVerificationView = false
    @Published var showVerification = false
    @Published var showResetPassword = false
    @Published var accessToken = ""
    @Published var refreshToken = ""
    
    let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager = .shared) {
        self.authManager = authManager
    }
    
    // Move validation logic from view to ViewModel
    func handleEmailContinue() -> Bool {
        if validateEmail() {
            showPasswordField = true
            return true
        }
        return false
    }
    
    func handleBackToEmail() {
        showPasswordField = false
        password = ""
        loginMessage = ""
    }
    
    func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if emailPredicate.evaluate(with: email) {
            loginMessage = ""
            return true
        } else {
            loginMessage = "Invalid Email"
            return false
        }
    }
    
    func validateAndLogin() async {
        isLoading = true
        loginMessage = ""
        
        do {
            let response = try await NetworkManager.shared.loginUser(email: email, password: password)
            isLoading = false
            self.accessToken = response.access_token
            self.refreshToken = response.refresh_token
            
            if response.msg.contains("verify your email") {
                showVerificationView = true
            } else {
                authManager.handleSuccessfulAuthentication(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token
                )
            }
        } catch {
            isLoading = false
            if let authError = error as? AuthError, case .emailNotVerified = authError {
                showVerification = true
            } else {
                loginMessage = error.localizedDescription
            }
        }
    }
    
    @MainActor
    func handleLogin() async {
        do {
            let response = try await NetworkManager.shared.loginUser(email: email, password: password)
            if response.msg.contains("verify your email") {
                showVerification = true
            } else {
                authManager.handleSuccessfulAuthentication(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token
                )
            }
        } catch {
            if let authError = error as? AuthError, case .emailNotVerified = authError {
                showVerification = true
            } else {
                loginMessage = error.localizedDescription
            }
        }
    }
    
    @MainActor
    func signInWithApple() async {
        do {
            try await authManager.signInWithApple()
        } catch {
            loginMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func signInWithGoogle() async {
        do {
            try await authManager.signInWithGoogle()
        } catch {
            loginMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func requestPasswordReset() async {
        guard !email.isEmpty else {
            loginMessage = "Please enter your email"
            return
        }
        
        isLoading = true
        loginMessage = ""
        
        do {
            _ = try await NetworkManager.shared.requestPasswordReset(email: email)
            isLoading = false
            showPasswordField = false
            password = ""
            showResetPassword = true
        } catch {
            isLoading = false
            if error.localizedDescription.contains("social authentication") {
                loginMessage = "Password reset is not available for accounts using Google or Apple Sign-In. Please use the social login option you originally signed up with."
            } else {
                loginMessage = error.localizedDescription
            }
        }
    }
}
