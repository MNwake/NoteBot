//
//  CustomButton.swift
//  HR Notes
//
//  Created by Theo Koester on 9/18/24.
//

import SwiftUI

struct CustomButton: View {
    var title: String
    var gradientColors: [Color] = [
        Color(red: 210/255, green: 230/255, blue: 245/255), // First color in the gradient
        Color(red: 115/255, green: 175/255, blue: 225/255) // Second color in the gradient
    ]
    var action: () -> Void  // Action to perform when the button is tapped
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .padding(.horizontal, 30)  // Same horizontal padding as the text fields
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 30)  // Ensuring the button has the same padding as the text fields
    }
}

