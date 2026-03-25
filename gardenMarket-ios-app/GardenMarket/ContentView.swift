import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                if authVM.currentUser?.isGardener == true {
                    GrowerTabView()
                } else {
                    MainTabView()
                }
            } else {
                LoginView()
            }
        }
        .animation(.default, value: authVM.isAuthenticated)
    }
}
