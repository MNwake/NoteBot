import SwiftUI

struct VerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: VerificationViewModel
    @FocusState private var isCodeFieldFocused: Bool
    
    init(
        email: String,
        accessToken: String,
        refreshToken: String,
        onVerificationComplete: (() -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: VerificationViewModel(
            email: email,
            accessToken: accessToken,
            refreshToken: refreshToken,
            onVerificationComplete: onVerificationComplete
        ))
    }
    
    var body: some View {
        ZStack {
            AuthenticationStyle.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                VStack(alignment: .leading, spacing: 20) {
                    Text("Verify Email")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Please enter the verification code sent to \(viewModel.email)")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                // Verification Code Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Verification Code")
                        .font(.system(size: 17, weight: .medium))
                    TextField("", text: $viewModel.verificationCode)
                        .textFieldStyle(.plain)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .focused($isCodeFieldFocused)
                }
                
                // Error/Success Message
                if !viewModel.message.isEmpty {
                    Text(viewModel.message)
                        .foregroundColor(viewModel.isVerified ? .green : .red)
                        .font(.system(size: 14))
                }
                
                // Verify Button
                Button(action: {
                    Task {
                        await viewModel.verifyEmail()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Verify")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AuthenticationStyle.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(viewModel.isLoading)
                
                // Resend Code Button
                Button(action: {
                    Task {
                        await viewModel.resendCode()
                    }
                }) {
                    Text("Didn't receive the code? Resend")
                        .foregroundColor(AuthenticationStyle.accentColor)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            isCodeFieldFocused = true
        }
    }
}

#Preview {
    NavigationView {
        VerificationView(email: "test@example.com", accessToken: "", refreshToken: "")
    }
} 