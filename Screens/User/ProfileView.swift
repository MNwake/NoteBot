import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                if let user = viewModel.currentUser {
                    if viewModel.isEditing {
                        TextField("Full Name", text: $viewModel.editedFullName)
                        TextField("Email", text: $viewModel.editedEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Phone Number", text: $viewModel.editedPhoneNumber)
                            .keyboardType(.phonePad)
                    } else {
                        HStack {
                            Text("Full Name")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.fullName)
                        }
                        
                        HStack {
                            Text("Email")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(user.email)
                        }
                        
                        if let phone = user.phoneNumber {
                            HStack {
                                Text("Phone")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(phone)
                            }
                        }
                    }
                } else {
                    if viewModel.isLoading {
                        ProgressView("Loading user information...")
                    } else {
                        Text("Please log in again")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if viewModel.isEditing {
                Section {
                    Button("Save Changes") {
                        Task {
                            await viewModel.saveChanges()
                        }
                    }
                    .disabled(viewModel.editedFullName.isEmpty || viewModel.editedEmail.isEmpty)
                    
                    Button("Cancel", role: .cancel) {
                        viewModel.isEditing = false
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    viewModel.showingLogoutAlert = true
                } label: {
                    Text("Logout")
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            if !viewModel.isEditing {
                Button("Edit") {
                    viewModel.startEditing()
                }
            }
        }
        .alert("Logout", isPresented: $viewModel.showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                Task {
                    await viewModel.logout()
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            await viewModel.fetchUserProfile()
        }
    }
} 