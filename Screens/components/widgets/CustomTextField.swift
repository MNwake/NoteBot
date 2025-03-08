//
//  CustomTextField.swift
//  HR Notes
//
//  Created by Theo Koester on 9/18/24.
//

import SwiftUI


struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.accentColor.opacity(0.6))  // Placeholder color
                    .padding(.leading, 10)  // Matches text padding
            }
            TextField("", text: $text)
                .padding(16)  // Internal padding within the text field
                .background(Color.white.opacity(0.2))  // Background color
                .cornerRadius(10)
                .foregroundColor(.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor.opacity(0.8), lineWidth: 1))
        }
        .padding(.horizontal, 30)  // Extra padding outside the text field
        .padding(.vertical, 5)  // Add some vertical spacing as well
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.accentColor.opacity(0.6))  // Placeholder color
                    .padding(.leading, 10)  // Matches text padding
            }
            SecureField("", text: $text)
                .padding(16)  // Internal padding within the text field
                .background(Color.white.opacity(0.2))  // Background color
                .cornerRadius(10)
                .foregroundColor(.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor.opacity(0.8), lineWidth: 1))
        }
        .padding(.horizontal, 30)  // Extra padding outside the text field
        .padding(.vertical, 5)  // Add some vertical spacing as well
    }
}

