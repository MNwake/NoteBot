import Foundation
import KeychainSwift
import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

enum AuthError: LocalizedError {
    case invalidResponse
    case serverError(String)
    case emailNotVerified(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from authentication"
        case .serverError(let message):
            return message
        case .emailNotVerified(_):
            return "Please verify your email first"
        }
    }
}

class AuthenticationManager: NSObject, ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    @Published var error: String?
    @Published var isLoading = false
    
    private let keychain = KeychainSwift()
    private let tokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"
    private let userKey = "user_profile"
    private let googleClientId = "your-google-client-id"
    
    private override init() {
        super.init()
        // Check for existing token
        if let _ = keychain.get(tokenKey) {
            isAuthenticated = true
            loadSavedUser()
        }
    }
    
    private func loadSavedUser() {
        if let userData = keychain.getData(userKey),
           let user = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            self.currentUser = user
        }
    }
    
    func login(email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let response = try await NetworkManager.shared.loginUser(email: email, password: password)
            await MainActor.run {
                self.handleSuccessfulAuthentication(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token
                )
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func register(fullName: String, email: String, password: String) async throws {
        isLoading = true
        error = nil
        
        do {
            // Create UserRegister struct to match NetworkManager's expected parameter
            let userRegister = UserRegister(
                email: email,
                password: password,
                full_name: fullName
            )
            
            let response = try await NetworkManager.shared.registerUser(user: userRegister)
            await MainActor.run {
                self.handleSuccessfulAuthentication(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token
                )
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signInWithApple() async throws {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // Present sign in
        controller.performRequests()
    }
    
    func signInWithGoogle() async throws {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            throw AuthError.serverError("Unable to present Google Sign In")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        // Remove optional binding since GIDGoogleUser is non-optional
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.invalidResponse
        }
        
        // Get user details
        let email = user.profile?.email
        let fullName = [
            user.profile?.givenName,
            user.profile?.familyName
        ].compactMap { $0 }.joined(separator: " ")
        
        // Send to backend
        let response = try await NetworkManager.shared.loginWithGoogle(
            idToken: idToken,
            email: email,
            fullName: fullName
        )
        
        await MainActor.run {
            self.handleSuccessfulAuthentication(
                accessToken: response.access_token,
                refreshToken: response.refresh_token
            )
        }
    }
    
    func handleSuccessfulAuthentication(accessToken: String, refreshToken: String) {
        keychain.set(accessToken, forKey: tokenKey)
        keychain.set(refreshToken, forKey: refreshTokenKey)
        isAuthenticated = true
        Task {
            await fetchUserProfile()
        }
    }
    
    func fetchUserProfile() async {
        do {
            let user = try await NetworkManager.shared.fetchUserProfile()
            await MainActor.run {
                self.saveUser(user)
            }
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }
    
    func logout() async {
        do {
            try await NetworkManager.shared.logout()
            await MainActor.run {
                self.clearAuthentication()
            }
        } catch {
            print("Error during logout: \(error)")
            // Still clear local auth state even if server request fails
            await MainActor.run {
                self.clearAuthentication()
            }
        }
    }
    
    func updateProfile(fullName: String, email: String, phoneNumber: String) async throws -> UserProfile {
        let profile = try await NetworkManager.shared.updateUserProfile(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
        )
        
        await MainActor.run {
            self.currentUser = profile
        }
        
        return profile
    }
    
    func clearAuthentication() {
        keychain.delete(tokenKey)
        keychain.delete(refreshTokenKey)
        keychain.delete(userKey)
        isAuthenticated = false
        currentUser = nil
    }
    
    private func saveUser(_ user: UserProfile) {
        if let encoded = try? JSONEncoder().encode(user) {
            keychain.set(encoded, forKey: userKey)
            self.currentUser = user
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                error = AuthError.invalidResponse.localizedDescription
                return
            }
            
            Task {
                do {
                    let response = try await NetworkManager.shared.loginWithApple(
                        identityToken: tokenString,
                        fullName: appleIDCredential.fullName.map { "\($0.givenName ?? "") \($0.familyName ?? "")" },
                        email: appleIDCredential.email
                    )
                    
                    await MainActor.run {
                        self.handleSuccessfulAuthentication(
                            accessToken: response.access_token,
                            refreshToken: response.refresh_token
                        )
                    }
                } catch {
                    await MainActor.run {
                        self.error = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.error = error.localizedDescription
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}

// Add this extension at the bottom of the file
extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}


 
