//
//  HR_NotesApp.swift
//  HR Notes
//
//  Created by Theo Koester on 9/14/24.
//

import SwiftUI
import GoogleSignIn

@main
struct NoteBotApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

struct AppTheme {
    // Define your gradient colors
    static let gradientColors: [Color] = [
        Color(red: 115/255, green: 175/255, blue: 225/255),
        Color(red: 210/255, green: 230/255, blue: 245/255)
        
    ]
    
    // Create a reusable gradient
    static let buttonGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: gradientColors),
        startPoint: .leading,
        endPoint: .trailing
    )
    // Reversed gradient
    static let reversedButtonGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: gradientColors),
        startPoint: .trailing,
        endPoint: .leading
    )
    
    // Define text and border color derived from the gradient
    
    
}
