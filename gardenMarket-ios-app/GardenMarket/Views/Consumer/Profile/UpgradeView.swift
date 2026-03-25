import SwiftUI

struct UpgradeView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Become a Grower")
                .font(.headline)
            Text("Complete at least one purchase to unlock grower tools.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Request Grower Access") {
                Task {
                    if let user = await viewModel.upgrade() {
                        authVM.currentUser = user
                    }
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoading)

            if let error = viewModel.error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
    }
}
