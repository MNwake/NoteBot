import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RegistrationViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case fullName, email, password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            AuthenticationStyle.backgroundColor
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header section
                    headerSection
                    
                    VStack(spacing: 25) {
                        switch viewModel.currentStep {
                        case .fullName:
                            fullNameSection
                        case .email:
                            emailSection
                        case .password:
                            passwordSection
                        }
                        
                        if viewModel.currentStep == .fullName {
                            socialSignupSection
                        }
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .sheet(isPresented: $viewModel.showVerificationView) {
            NavigationView {
                VerificationView(
                    email: viewModel.email,
                    accessToken: viewModel.accessToken,
                    refreshToken: viewModel.refreshToken,
                    onVerificationComplete: {
                        dismiss()
                    }
                )
            }
            .environmentObject(viewModel.authManager)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sign Up")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Create your account")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        .padding(.horizontal, 30)
    }
    
    private var fullNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Full Name")
                .font(.system(size: 17, weight: .medium))
            
            TextField("", text: $viewModel.fullName)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .focused($focusedField, equals: .fullName)
                .submitLabel(.next)
                .onSubmit(viewModel.validateAndContinueFromName)
            
            if !viewModel.registerMessage.isEmpty {
                Text(viewModel.registerMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            Button(action: viewModel.validateAndContinueFromName) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AuthenticationStyle.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.system(size: 17, weight: .medium))
            
            TextField("", text: $viewModel.email)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit(viewModel.validateAndContinueFromEmail)
            
            if !viewModel.registerMessage.isEmpty {
                Text(viewModel.registerMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            Button(action: viewModel.validateAndContinueFromEmail) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AuthenticationStyle.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Create Password")
                .font(.system(size: 17, weight: .medium))
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .confirmPassword
                }
                .textContentType(.newPassword)
            
            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit {
                    Task {
                        await viewModel.validateAndRegister()
                    }
                }
                .textContentType(.newPassword)
            
            if !viewModel.registerMessage.isEmpty {
                Text(viewModel.registerMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            Button(action: {
                Task {
                    await viewModel.validateAndRegister()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AuthenticationStyle.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    private var socialSignupSection: some View {
        VStack(spacing: 15) {
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
                Text("or")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            SignInWithAppleButton(action: {
                Task {
                    await viewModel.signUpWithApple()
                }
            }, label: "Sign up with Apple")
            
            SignInWithGoogleButton(action: {
                Task {
                    await viewModel.signUpWithGoogle()
                }
            }, label: "Sign up with Google")
            
            // Login Link
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.primary)
                Button(action: { dismiss() }) {
                    Text("Log in")
                        .foregroundColor(AuthenticationStyle.accentColor)
                }
            }
            .font(.system(size: 15))
        }
        .padding(.top, 10)
    }
    
    private var backButton: some View {
        Button(action: viewModel.goToPreviousStep) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationView {
        RegistrationView()
    }
}
