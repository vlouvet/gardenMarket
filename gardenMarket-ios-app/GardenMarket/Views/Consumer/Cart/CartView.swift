import SwiftUI

struct CartView: View {
    @State private var viewModel = CartViewModel()
    @State private var showCheckout = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.cart == nil {
                    ProgressView()
                } else if viewModel.itemCount == 0 {
                    ContentUnavailableView(
                        "Cart is Empty",
                        systemImage: "cart",
                        description: Text("Browse listings to add items.")
                    )
                } else {
                    List {
                        ForEach(viewModel.cart?.items ?? []) { item in
                            CartItemRow(item: item) {
                                Task { await viewModel.removeItem(id: item.id) }
                            }
                        }

                        Section {
                            Button {
                                showCheckout = true
                            } label: {
                                Label("Proceed to Checkout", systemImage: "creditcard")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .navigationTitle("Cart (\(viewModel.itemCount))")
            .refreshable { await viewModel.loadCart() }
            .task { await viewModel.loadCart() }
            .sheet(isPresented: $showCheckout) {
                CheckoutView {
                    viewModel.cart = nil
                    Task { await viewModel.loadCart() }
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
    }
}

struct CartItemRow: View {
    let item: CartItem
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Listing #\(item.listing)")
                    .font(.headline)
                Text("Qty: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive) { onRemove() } label: {
                Image(systemName: "trash")
            }
        }
    }
}
