import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    @State private var serverURL: String = UserDefaults.standard.string(forKey: "server_url") ?? "http://192.168.1.42:8000"

    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    TextField("Server URL", text: $serverURL)
                        #if os(iOS)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        #endif

                    Button("Save") {
                        UserDefaults.standard.set(serverURL, forKey: "server_url")
                    }
                }

                Section("Account") {
                    if let user = authVM.currentUser {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email).foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Role")
                            Spacer()
                            Text(user.role.capitalized).foregroundStyle(.secondary)
                        }
                    }

                    Button("Log Out", role: .destructive) {
                        authVM.logout()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
