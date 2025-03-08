//
//  SignInWithGoogleButton.swift
//  NoteBot
//
//  Created by Theo Koester on 3/2/25.
//

import SwiftUI

import SwiftUI

struct SignInWithGoogleButton: View {
    let action: () -> Void
    let label: String
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image("google_logo") // Add this to your assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .foregroundColor(.black)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
