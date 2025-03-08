//
//  LoginView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/18/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 25) {
                        // Logo
                        Image("notebot_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.top, 60)
                        
                        Text("Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 20) {
                            if !viewModel.showPasswordField {
                                emailSection
                            } else {
                                passwordSection
                            }
                            
                            // Register Link
                            NavigationLink(destination: RegistrationView()) {
                                Text("Don't have an account? ")
                                    .foregroundColor(.primary) +
                                Text("Sign up")
                                    .foregroundColor(AuthenticationStyle.accentColor)
                            }
                            .font(.subheadline)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
            .background(AuthenticationStyle.backgroundColor.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showVerificationView) {
                NavigationView {
                    VerificationView(
                        email: viewModel.email,
                        accessToken: viewModel.accessToken,
                        refreshToken: viewModel.refreshToken
                    )
                }
            }
            .sheet(isPresented: $viewModel.showVerification) {
                NavigationView {
                    VerificationView(
                        email: viewModel.email,
                        accessToken: "",
                        refreshToken: "",
                        onVerificationComplete: {
                            Task {
                                await viewModel.handleLogin()
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $viewModel.showResetPassword) {
                NavigationView {
                    ResetPasswordView(email: viewModel.email)
                }
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
                .onSubmit {
                    if viewModel.validateEmail() {
                        withAnimation {
                            viewModel.showPasswordField = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                focusedField = .password
                            }
                        }
                    }
                }
            
            if !viewModel.loginMessage.isEmpty {
                Text(viewModel.loginMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            Button(action: {
                if viewModel.validateEmail() {
                    withAnimation {
                        viewModel.showPasswordField = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusedField = .password
                        }
                    }
                }
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AuthenticationStyle.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            // Social login options
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
                        await viewModel.signInWithApple()
                    }
                }, label: "Continue with Apple")
                
                SignInWithGoogleButton(action: {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }, label: "Continue with Google")
            }
            .padding(.top, 20)
        }
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.system(size: 17, weight: .medium))
            
            SecureField("", text: $viewModel.password)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.done)
                .onSubmit {
                    Task {
                        await viewModel.validateAndLogin()
                    }
                }
            
            if !viewModel.loginMessage.isEmpty {
                Text(viewModel.loginMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            // Add Forgot Password button
            Button(action: {
                Task {
                    await viewModel.requestPasswordReset()
                }
            }) {
                Text("Forgot Password?")
                    .font(.system(size: 14))
            }
            .foregroundColor(AuthenticationStyle.accentColor)
            .padding(.top, 5)
            
            Button(action: {
                Task {
                    await viewModel.validateAndLogin()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Login")
                }
            }
            .authButtonStyle()
            .disabled(viewModel.isLoading)
            .padding(.top, 10)
            
            Button(action: { 
                viewModel.showPasswordField = false
                viewModel.password = ""
                viewModel.loginMessage = ""
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Use different email")
                }
            }
            .foregroundColor(.primary)
            .padding(.top, 5)
        }
    }
}

#Preview {
    LoginView()
}

