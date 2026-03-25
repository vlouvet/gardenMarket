import SwiftUI

struct ListingDetailView: View {
    let listingId: Int
    @State private var listing: Listing?
    @State private var isLoading = true
    @State private var quantity = 1
    @State private var addedToCart = false
    @State private var error: String?

    private let listingService = ListingService()
    private let cartService = CartService()

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let listing {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(height: 200)
                            .overlay {
                                Image(systemName: "leaf")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.secondary)
                            }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(listing.displayType)
                                    .font(.title2.bold())
                                Spacer()
                                Text(listing.price.description)
                                    .font(.title2.bold())
                                    .foregroundStyle(.accent)
                                + Text(" / \(listing.displayUnit)")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }

                            if let distance = listing.distanceMiles {
                                Label("\(Int(distance)) miles away", systemImage: "mappin.and.ellipse")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let window = listing.pickupWindow, !window.isEmpty {
                                Label(window, systemImage: "clock")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Text("Available: \(listing.quantityAvailable) \(listing.displayUnit)")
                                Spacer()
                                if listing.growerVerified == true {
                                    Label("Verified", systemImage: "checkmark.seal.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                            .font(.subheadline)
                        }

                        Divider()

                        HStack {
                            Stepper("Qty: \(quantity)", value: $quantity, in: 1...listing.quantityAvailable)
                        }

                        Button {
                            Task {
                                do {
                                    _ = try await cartService.addItem(listingId: listing.id, quantity: quantity)
                                    addedToCart = true
                                } catch let err as APIError {
                                    error = err.errorDescription
                                } catch {
                                    self.error = error.localizedDescription
                                }
                            }
                        } label: {
                            Label(addedToCart ? "Added to Cart" : "Add to Cart", systemImage: addedToCart ? "checkmark" : "cart.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(addedToCart)

                        if let error {
                            Text(error).foregroundStyle(.red).font(.caption)
                        }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView("Listing not found", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Listing")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            do {
                listing = try await listingService.fetchListing(id: listingId)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}
