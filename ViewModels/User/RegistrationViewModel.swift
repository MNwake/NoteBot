//
//  RegistrationViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/5/25.
//

import Foundation
import SwiftUI

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var fullName = ""
    @Published var registerMessage = ""
    @Published var isLoading = false
    @Published var showVerificationView = false
    @Published var accessToken = ""
    @Published var refreshToken = ""
    @Published var currentStep = RegistrationStep.fullName
    
    enum RegistrationStep {
        case fullName, email, password
    }
    
    let authManager: AuthenticationManager
    
    init(authManager: AuthenticationManager = .shared) {
        self.authManager = authManager
    }
    
    func validateAndContinueFromName() {
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            registerMessage = "Please enter your full name"
            return
        }
        registerMessage = ""
        currentStep = .email
    }
    
    func validateAndContinueFromEmail() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if emailPredicate.evaluate(with: email) {
            registerMessage = ""
            currentStep = .password
        } else {
            registerMessage = "Invalid Email"
        }
    }
    
    func goToPreviousStep() {
        registerMessage = ""
        switch currentStep {
        case .email:
            currentStep = .fullName
        case .password:
            currentStep = .email
        case .fullName:
            break
        }
    }
    
    @MainActor
    func validateAndRegister() async {
        guard password == confirmPassword else {
            registerMessage = "Passwords do not match"
            return
        }
        
        guard isPasswordValid(password) else {
            registerMessage = "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number"
            return
        }
        
        let user = UserRegister(
            email: email,
            password: password,
            full_name: fullName
        )
        
        if let validationError = user.validate() {
            registerMessage = validationError
            return
        }
        
        isLoading = true
        registerMessage = ""
        
        do {
            let response = try await NetworkManager.shared.registerUser(user: user)
            isLoading = false
            self.accessToken = response.access_token
            self.refreshToken = response.refresh_token
            showVerificationView = true
        } catch {
            isLoading = false
            registerMessage = error.localizedDescription
        }
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        // Password must be at least 8 characters long
        guard password.count >= 8 else { return false }
        
        // Check for at least one uppercase letter
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil else { return false }
        
        // Check for at least one lowercase letter
        guard password.range(of: "[a-z]", options: .regularExpression) != nil else { return false }
        
        // Check for at least one number
        guard password.range(of: "[0-9]", options: .regularExpression) != nil else { return false }
        
        return true
    }
    
    @MainActor
    func signUpWithApple() async {
        do {
            try await authManager.signInWithApple()
        } catch {
            registerMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func signUpWithGoogle() async {
        do {
            try await authManager.signInWithGoogle()
        } catch {
            registerMessage = error.localizedDescription
        }
    }
}
