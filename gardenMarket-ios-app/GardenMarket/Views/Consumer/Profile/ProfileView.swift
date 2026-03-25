import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var viewModel = ProfileViewModel()
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = "US"
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Address") {
                    TextField("Address Line 1", text: $addressLine1)
                    TextField("Address Line 2", text: $addressLine2)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("Postal Code", text: $postalCode)
                    TextField("Country", text: $country)
                }

                if let lat = viewModel.profile?.lat, let lon = viewModel.profile?.lon {
                    Section("Location") {
                        Text("Lat: \(lat, specifier: "%.4f"), Lon: \(lon, specifier: "%.4f")")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Save Profile") {
                        Task {
                            await viewModel.saveProfile(ProfileUpdate(
                                addressLine1: addressLine1,
                                addressLine2: addressLine2,
                                city: city,
                                state: state,
                                postalCode: postalCode,
                                country: country
                            ))
                        }
                    }
                    .disabled(viewModel.isLoading)
                }

                if let msg = viewModel.successMessage {
                    Section { Text(msg).foregroundStyle(.green) }
                }
                if let err = viewModel.error {
                    Section { Text(err).foregroundStyle(.red) }
                }

                if authVM.currentUser?.isConsumer == true {
                    Section("Upgrade") {
                        UpgradeView()
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .task {
                await viewModel.loadProfile()
                if let p = viewModel.profile {
                    addressLine1 = p.addressLine1 ?? ""
                    addressLine2 = p.addressLine2 ?? ""
                    city = p.city ?? ""
                    state = p.state ?? ""
                    postalCode = p.postalCode ?? ""
                    country = p.country ?? "US"
                }
            }
        }
    }
}
