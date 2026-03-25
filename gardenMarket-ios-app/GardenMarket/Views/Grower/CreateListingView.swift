import SwiftUI

struct CreateListingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GrowerDashboardViewModel()
    @State private var selectedPlant: Int?
    @State private var type = "PRODUCE"
    @State private var unit = "lb"
    @State private var price = ""
    @State private var quantity = ""
    @State private var pickupWindow = ""
    var onCreated: () -> Void

    private let types = [("PRODUCE", "Produce"), ("SEEDS", "Seeds"), ("CLIPPING", "Clipping")]
    private let units = [("each", "Each"), ("gram", "Gram"), ("lb", "Pound"), ("bundle", "Bundle")]

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant") {
                    if viewModel.plants.isEmpty {
                        Text("No plants. Create a plant profile first.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Plant", selection: $selectedPlant) {
                            Text("Select plant").tag(nil as Int?)
                            ForEach(viewModel.plants) { plant in
                                Text(plant.name).tag(plant.id as Int?)
                            }
                        }
                    }
                }

                Section("Details") {
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.0) { val, label in Text(label).tag(val) }
                    }
                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.0) { val, label in Text(label).tag(val) }
                    }
                    TextField("Price", text: $price)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    TextField("Quantity Available", text: $quantity)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    TextField("Pickup Window", text: $pickupWindow)
                }

                if let error = viewModel.error {
                    Section { Text(error).foregroundStyle(.red) }
                }

                Section {
                    Button("Create Listing") {
                        guard let plant = selectedPlant, let qty = Int(quantity) else { return }
                        Task {
                            await viewModel.createListing(CreateListingRequest(
                                plant: plant,
                                type: type,
                                unit: unit,
                                price: price,
                                quantityAvailable: qty,
                                pickupWindow: pickupWindow.isEmpty ? nil : pickupWindow,
                                pickupDays: nil
                            ))
                            if viewModel.error == nil {
                                onCreated()
                                dismiss()
                            }
                        }
                    }
                    .disabled(selectedPlant == nil || price.isEmpty || quantity.isEmpty)
                }
            }
            .navigationTitle("New Listing")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task { await viewModel.loadPlants() }
        }
    }
}
