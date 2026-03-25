import SwiftUI

struct EditListingView: View {
    let listingId: Int
    @State private var listing: Listing?
    @State private var price = ""
    @State private var quantity = ""
    @State private var pickupWindow = ""
    @State private var status = "active"
    @State private var isLoading = true
    @State private var error: String?
    @State private var saved = false

    private let listingService = ListingService()
    private let statuses = [("active", "Active"), ("paused", "Paused")]

    var body: some View {
        Form {
            if isLoading {
                ProgressView()
            } else if listing != nil {
                Section("Update") {
                    TextField("Price", text: $price)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    TextField("Quantity", text: $quantity)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    TextField("Pickup Window", text: $pickupWindow)
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.0) { val, label in Text(label).tag(val) }
                    }
                }

                Section {
                    Button("Save Changes") {
                        Task {
                            do {
                                _ = try await listingService.updateListing(id: listingId, UpdateListingRequest(
                                    price: price.isEmpty ? nil : price,
                                    quantityAvailable: Int(quantity),
                                    pickupWindow: pickupWindow.isEmpty ? nil : pickupWindow,
                                    status: status
                                ))
                                saved = true
                            } catch let err as APIError {
                                error = err.errorDescription
                            } catch {
                                self.error = error.localizedDescription
                            }
                        }
                    }
                }

                if saved { Section { Text("Saved.").foregroundStyle(.green) } }
                if let error { Section { Text(error).foregroundStyle(.red) } }
            }
        }
        .navigationTitle("Edit Listing")
        .task {
            do {
                listing = try await listingService.fetchListing(id: listingId)
                if let l = listing {
                    price = "\(l.price.value)"
                    quantity = "\(l.quantityAvailable)"
                    pickupWindow = l.pickupWindow ?? ""
                    status = l.status
                }
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}
