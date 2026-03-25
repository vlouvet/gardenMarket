import SwiftUI

struct ListingsGridView: View {
    @State private var viewModel = ListingsViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sticky filter bar – stays pinned above the scroll area
                ListingFilterBar(filter: $viewModel.filter) {
                    Task { await viewModel.loadListings() }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                .background(.bar)

                Divider()

                // Scrollable content
                ScrollViewReader { proxy in
                    ScrollView {
                        Color.clear.frame(height: 0)
                            .id("top")

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

                            Button {
                                withAnimation {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                            } label: {
                                Label("Back to Top", systemImage: "arrow.up")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                            .padding(.bottom, 24)
                        }
                    }
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
