//
//  config.swift
//  NoteBot
//
//  Created by Theo Koester on 3/6/25.
//

import Foundation


enum Config {
    // Development URL (when running locally)
    // static let apiBaseUrl = "http://localhost:8000"
    
    // Production URL (your actual server)
    static let apiBaseUrl = "https://koesterventures.com/notebot"  // Replace with your actual API URL
    
    // Other configuration values can go here
    static let appName = "NoteBot"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
}
