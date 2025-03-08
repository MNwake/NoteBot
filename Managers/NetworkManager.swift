//
//  NetworkManager.swift
//  HR Notes
//
//  Created by Theo Koester on 9/18/24.
//

import Foundation
import Alamofire
import KeychainSwift

enum NetworkError: Error {
    case unauthorized
    case serverError
    case invalidData(String)
    case invalidCredentials
    case invalidURL
    case invalidRequestBody
    case invalidResponse
    case forbidden
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid Email/Password"
        case .invalidURL:
            return "Invalid URL"
        case .invalidRequestBody:
            return "Invalid request format"
        case .invalidResponse:
            return "Invalid response format"
        case .serverError:
            return "Server error"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Access forbidden - Please check your authentication"
        case .invalidData(let message):
            return message
        }
    }
}

struct ErrorResponse: Codable {
    let detail: String
}

// Add this model
struct AppleAuthRequest: Codable {
    let identity_token: String
    let full_name: String?
    let email: String?
}

struct GoogleAuthRequest: Codable {
    let id_token: String
    let email: String?
    let full_name: String?
}

// Add this model at the bottom of the file with other models
struct MessageResponse: Codable {
    let msg: String
}

// Make sure these match the backend response types
struct AuthResponse: Codable {
    let access_token: String
    let refresh_token: String
    let msg: String
    let user_id: String
}

struct TokenRefreshResponse: Codable {
    let access_token: String
    let msg: String
}

// Update the UploadResponse struct to match what we need
struct UploadResponse: Codable {
    let message: String
    let documentId: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case documentId = "document_id"
        case status
    }
}

// Update the QueueStatusResponse struct to match the backend model
struct QueueStatusResponse: Codable {
    let user_id: String
    let document_id: String
    let file_path: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case document_id
        case file_path
        case status
    }
}

class NetworkManager: ObservableObject {
    
    static let shared = NetworkManager()
    let baseUrl: String
    let session: Session
    
    private init() {
        self.baseUrl = Config.apiBaseUrl
        
        // Initialize session with interceptor
        let interceptor = AuthenticationInterceptor()
        self.session = Session(interceptor: interceptor)
    }
    
    // MARK: - Authentication
    func loginUser(email: String, password: String) async throws -> AuthResponse {
        let parameters = UserLogin(email: email, password: password)
        return try await AF.request("\(baseUrl)/login",
                                 method: .post,
                                 parameters: parameters,
                                 encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(AuthResponse.self)
            .value
    }
    
    func registerUser(user: UserRegister) async throws -> AuthResponse {
        return try await session.request("\(baseUrl)/register",
                                      method: .post,
                                      parameters: user,
                                      encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(AuthResponse.self)
            .value
    }
    
    func loginWithApple(identityToken: String, fullName: String?, email: String?) async throws -> AuthResponse {
        let parameters = AppleAuthRequest(
            identity_token: identityToken,
            full_name: fullName,
            email: email
        )
        
        return try await session.request("\(baseUrl)/apple-login",
                                      method: .post,
                                      parameters: parameters,
                                      encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(AuthResponse.self)
            .value
    }
    
    // MARK: - Profile Management
    func fetchUserProfile() async throws -> UserProfile {
        return try await session.request("\(baseUrl)/user/profile",
                                      method: .get)
            .validate()
            .serializingDecodable(UserProfile.self)
            .value
    }
    
    func updateUserProfile(fullName: String, email: String, phoneNumber: String?) async throws -> UserProfile {
        let parameters = [
            "fullName": fullName,
            "email": email,
            "phoneNumber": phoneNumber
        ].compactMapValues { $0 }
        
        return try await session.request("\(baseUrl)/user/profile",
                                      method: .put,
                                      parameters: parameters,
                                      encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(UserProfile.self)
            .value
    }
    
    // MARK: - Call Details
    func sendCallDetailsToBackend(fileURL: URL, callDetails: CallDetails) async throws -> UploadResponse {
        // Verify authentication first
        guard AuthenticationManager.shared.isAuthenticated else {
            throw NetworkError.unauthorized
        }
        
        let url = "\(baseUrl)/upload_audio"
        let sessionId = UUID().uuidString
        
        return try await session.upload(
            multipartFormData: { multipartFormData in
                // Add session ID and chunk info
                multipartFormData.append(sessionId.data(using: .utf8)!, withName: "session_id")
                multipartFormData.append("0".data(using: .utf8)!, withName: "chunk_index")
                multipartFormData.append("1".data(using: .utf8)!, withName: "total_chunks")
                
                // Add call details
                if let callDetailsData = try? JSONEncoder().encode(callDetails) {
                    multipartFormData.append(
                        callDetailsData,
                        withName: "call_details"
                    )
                }
                
                // Add the audio file
                if let audioData = try? Data(contentsOf: fileURL) {
                    multipartFormData.append(
                        audioData,
                        withName: "file",
                        fileName: "\(sessionId).m4a",
                        mimeType: "audio/x-m4a"
                    )
                }
            },
            to: url,
            method: .post
        )
        .validate()
        .serializingDecodable(UploadResponse.self)
        .value
    }
    
    // Then update the getCallDetails method
    func getCallDetails() async throws -> [CallDetails] {
        return try await session.request("\(baseUrl)/notes",
                                     method: .get)
            .validate()
            .serializingDecodable(CallDetailsResponse.self)
            .value
            .call_details
    }

    // Add logout endpoint
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/logout") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addAuthHeader(&request)
        
        _ = session.request(request).validate().response { response in
            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Add token handling to existing methods
    private func addAuthHeader(_ request: inout URLRequest) {
        if let token = KeychainSwift().get("auth_token") {
            request.headers.add(.authorization(bearerToken: token))
        }
    }

    // Add these new methods to the NetworkManager class
    func verifyEmail(code: String) async throws -> String {
        return try await session.request("\(baseUrl)/verify-email/\(code)",
                                      method: .get)
            .validate()
            .serializingDecodable(VerificationResponse.self)
            .value
            .msg
    }
    
    func resendVerificationCode(email: String) async throws -> String {
        return try await session.request("\(baseUrl)/resend-verification",
                                      method: .post,
                                      parameters: ["email": email],
                                      encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(VerificationResponse.self)
            .value
            .msg
    }

    func loginWithGoogle(idToken: String, email: String?, fullName: String?) async throws -> AuthResponse {
        let parameters = GoogleAuthRequest(
            id_token: idToken,
            email: email,
            full_name: fullName
        )
        
        return try await session.request("\(baseUrl)/google-login",
                                      method: .post,
                                      parameters: parameters,
                                      encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(AuthResponse.self)
            .value
    }

    func requestPasswordReset(email: String) async throws -> String {
        return try await session.request("\(baseUrl)/request-password-reset",
                                      method: .post,
                                      parameters: ["email": email],
                                      encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(MessageResponse.self)
            .value
            .msg
    }

    func resetPassword(code: String, newPassword: String) async throws -> String {
        let parameters = [
            "code": code,
            "new_password": newPassword
        ]
        
        return try await session.request("\(baseUrl)/reset-password",
                                      method: .post,
                                      parameters: parameters,
                                      encoder: JSONParameterEncoder.default)
            .validate()
            .serializingDecodable(VerificationResponse.self)
            .value
            .msg
    }

    func verifyPasswordResetCode(code: String) async throws -> String {
        return try await session.request("\(baseUrl)/verify-reset-code/\(code)",
                                      method: .get)
            .validate()
            .serializingDecodable(VerificationResponse.self)
            .value
            .msg
    }

    // MARK: - Session Management
    func logout() async throws {
        _ = try await session.request("\(baseUrl)/logout",
                                  method: .post)
            .validate()
            .serializingString()
    }

    // Add this method to NetworkManager class
    func getQueueStatus() async throws -> [QueueStatusResponse] {
        return try await session.request("\(baseUrl)/queue-status",
                                      method: .get)
            .validate()
            .serializingDecodable([QueueStatusResponse].self)
            .value
    }
}


 
// MARK: - Authentication Interceptor
class AuthenticationInterceptor: RequestInterceptor {
    private let keychain = KeychainSwift()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Add auth token if available
        if let token = keychain.get("auth_token") {
            urlRequest.headers.add(.authorization(bearerToken: token))
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        // Try to refresh token
        Task {
            do {
                let newToken = try await refreshToken()
                keychain.set(newToken, forKey: "auth_token")
                completion(.retry)
            } catch {
                AuthenticationManager.shared.clearAuthentication()
                completion(.doNotRetry)
            }
        }
    }
    
    private func refreshToken() async throws -> String {
        guard let refreshToken = keychain.get("refresh_token") else {
            throw NetworkError.unauthorized
        }
        
        let response = try await AF.request("\(NetworkManager.shared.baseUrl)/refresh-token",
                                         method: .post,
                                         headers: [.authorization(bearerToken: refreshToken)])
            .validate()
            .serializingDecodable(TokenRefreshResponse.self)
            .value
        
        return response.access_token
    }
}





