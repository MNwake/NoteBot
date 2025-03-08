//
//  SignInWithAppleButton.swift
//  NoteBot
//
//  Created by Theo Koester on 3/1/25.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: View {
    let action: () -> Void
    let label: String
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "apple.logo")
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.primary)
        .foregroundColor(AuthenticationStyle.backgroundColor)
        .cornerRadius(12)
    }
}
