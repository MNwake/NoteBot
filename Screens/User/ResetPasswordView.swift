import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ResetPasswordViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case code, password, confirmPassword
    }
    
    init(email: String) {
        _viewModel = StateObject(wrappedValue: ResetPasswordViewModel(email: email))
    }
    
    var body: some View {
        ZStack {
            AuthenticationStyle.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Reset Password")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Please enter the verification code sent to \(viewModel.email)")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    if !viewModel.showingPasswordFields {
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
                                .focused($focusedField, equals: .code)
                                .textContentType(.oneTimeCode)
                        }
                    } else {
                        // Password Fields
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("New Password")
                                    .font(.system(size: 17, weight: .medium))
                                SecureField("", text: $viewModel.newPassword)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .focused($focusedField, equals: .password)
                                    .textContentType(.newPassword)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 17, weight: .medium))
                                SecureField("", text: $viewModel.confirmPassword)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .textContentType(.newPassword)
                            }
                        }
                    }
                    
                    // Error/Success Message
                    if !viewModel.message.isEmpty {
                        Text(viewModel.message)
                            .foregroundColor(viewModel.isVerified ? .green : .red)
                            .font(.system(size: 14))
                    }
                    
                    // Action Button
                    Button(action: {
                        Task {
                            if viewModel.showingPasswordFields {
                                await viewModel.resetPassword()
                            } else {
                                await viewModel.verifyCode()
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(viewModel.showingPasswordFields ? "Reset Password" : "Verify")
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
                    if !viewModel.showingPasswordFields {
                        Button(action: {
                            Task {
                                await viewModel.resendCode()
                            }
                        }) {
                            Text("Didn't receive the code? Resend")
                                .foregroundColor(AuthenticationStyle.accentColor)
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
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
            focusedField = .code
        }
        .onChange(of: viewModel.isVerified) { isVerified in
            if isVerified {
                // Dismiss after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}
