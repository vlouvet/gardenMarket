import SwiftUI

struct ListingsGridView: View {
    @State private var viewModel = ListingsViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                ListingFilterBar(filter: $viewModel.filter) {
                    Task { await viewModel.loadListings() }
                }
                .padding(.horizontal)

                if viewModel.isLoading && viewModel.listings.isEmpty {
                    ProgressView("Loading listings...")
                        .padding(.top, 40)
                } else if viewModel.listings.isEmpty {
                    ContentUnavailableView(
                        "No Listings",
                        systemImage: "leaf.arrow.triangle.circlepath",
                        description: Text("No listings match your filters.")
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.listings) { listing in
                            NavigationLink(value: listing.id) {
                                ListingCardView(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Browse")
            .navigationDestination(for: Int.self) { id in
                ListingDetailView(listingId: id)
            }
            .refreshable {
                await viewModel.loadListings()
            }
            .task {
                await viewModel.loadListings()
            }
        }
    }
}
