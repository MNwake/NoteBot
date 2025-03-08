//
//  VerificationViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/5/25.
//

import Foundation
import SwiftUI

class VerificationViewModel: ObservableObject {
    @Published var verificationCode = ""
    @Published var message = ""
    @Published var isLoading = false
    @Published var isVerified = false
    
    let email: String
    let accessToken: String
    let refreshToken: String
    private let authManager: AuthenticationManager
    var onVerificationComplete: (() -> Void)?
    
    init(
        email: String,
        accessToken: String,
        refreshToken: String,
        authManager: AuthenticationManager = .shared,
        onVerificationComplete: (() -> Void)? = nil
    ) {
        self.email = email
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.authManager = authManager
        self.onVerificationComplete = onVerificationComplete
    }
    
    @MainActor
    func verifyEmail() async {
        isLoading = true
        message = ""
        
        do {
            let response = try await NetworkManager.shared.verifyEmail(code: verificationCode)
            isVerified = true
            message = response
            
            // First store the tokens
            authManager.handleSuccessfulAuthentication(
                accessToken: accessToken,
                refreshToken: refreshToken
            )
            
            // Call completion after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.onVerificationComplete?()
            }
        } catch {
            isLoading = false
            message = error.localizedDescription
        }
    }
    
    @MainActor
    func resendCode() async {
        do {
            let response = try await NetworkManager.shared.resendVerificationCode(email: email)
            message = response
        } catch {
            message = error.localizedDescription
        }
    }
}
