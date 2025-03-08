//
//  UserModel.swift
//  HR Notes
//
//  Created by Theo Koester on 9/18/24.
//

import Foundation


// Swift struct for user registration input, matching the Python models
struct UserRegister: Codable {
    var email: String
    var password: String
    var full_name: String  // Using snake_case to match backend
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case full_name
    }
    
    // Input validation for registration
    func validate() -> String? {
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailTest.evaluate(with: email) {
            return "Invalid email format"
        }
        
        // Validate password length
        if password.count < 8 {
            return "Password must be at least 8 characters"
        }
        
        // Validate full name
        if full_name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Full name is required"
        }
        
        return nil
    }
}

// Swift struct for user login input
struct UserLogin: Codable {
    var email: String
    var password: String
    
    // Input validation for login
    func validate() -> String? {
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailTest.evaluate(with: email) {
            return "Please enter a valid email address."
        }
        
        // Validate password (non-empty)
        if password.isEmpty {
            return "Password cannot be empty."
        }
        
        
        return nil // All validations passed
    }
}

// User model for authenticated user data
struct UserProfile: Codable {
    let email: String
    let fullName: String
    let userId: String
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case fullName = "fullName"  // Changed from "full_name" to match backend
        case userId = "userId"
        case phoneNumber = "phoneNumber" 
    }
}

// Add response models to match backend
struct LoginResponse: Codable {
    let msg: String
    let user_id: String
    let access_token: String
    let refresh_token: String
}

struct RegisterResponse: Codable {
    let msg: String
    let user_id: String
    let access_token: String
    let refresh_token: String
}

struct VerificationResponse: Codable {
    let msg: String
    
    // Add custom decoding if needed
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Try to decode as string first
        if let message = try? container.decode(String.self, forKey: .msg) {
            self.msg = message
        } else {
            // If that fails, try to decode as dictionary
            let dict = try container.decode([String: String].self, forKey: .msg)
            self.msg = dict["msg"] ?? "Email verified successfully"
        }
    }
}
