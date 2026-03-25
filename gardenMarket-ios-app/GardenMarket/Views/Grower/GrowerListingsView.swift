import SwiftUI

struct GrowerListingsView: View {
    @State private var viewModel = GrowerDashboardViewModel()
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.listings.isEmpty {
                    ContentUnavailableView("No Listings", systemImage: "leaf", description: Text("Create your first listing."))
                } else {
                    List(viewModel.listings) { listing in
                        NavigationLink(value: listing.id) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(listing.displayType)
                                        .font(.headline)
                                    Text("\(listing.price.description) / \(listing.displayUnit)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("Qty: \(listing.quantityAvailable)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                StatusBadge(status: listing.status)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Listings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Int.self) { id in
                EditListingView(listingId: id)
            }
            .sheet(isPresented: $showCreate) {
                CreateListingView {
                    Task { await viewModel.loadListings() }
                }
            }
            .task { await viewModel.loadListings() }
        }
    }
}
