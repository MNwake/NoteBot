import SwiftUI

struct AuthenticationStyle {
    static let backgroundColor = Color(red: 201/255, green: 207/255, blue: 212/255)
    static let accentColor = Color(red: 115/255, green: 175/255, blue: 225/255)
    
    struct TextFieldStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    struct PrimaryButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(accentColor)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

extension View {
    func authTextFieldStyle() -> some View {
        self.modifier(AuthenticationStyle.TextFieldStyle())
    }
    
    func authButtonStyle() -> some View {
        self.modifier(AuthenticationStyle.PrimaryButtonStyle())
    }
} 