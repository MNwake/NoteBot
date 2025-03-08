import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color matching the logo
                Color(red: 186/255, green: 192/255, blue: 199/255)
                    .ignoresSafeArea()
                
                if authManager.isAuthenticated {
                    MainRecordingView()
                } else {
                    LoginView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
            // This ensures we're on the main thread when updating the UI
            DispatchQueue.main.async {
                // The view will automatically update when isAuthenticated changes
                authManager.isAuthenticated = false
            }
        }
    }
}
