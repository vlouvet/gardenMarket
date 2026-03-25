import SwiftUI

struct GrowerOrdersView: View {
    @State private var viewModel = OrderViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView()
                } else if viewModel.orders.isEmpty {
                    ContentUnavailableView("No Orders", systemImage: "bag", description: Text("Orders for your listings will appear here."))
                } else {
                    List(viewModel.orders) { order in
                        OrderRow(order: order)
                    }
                }
            }
            .navigationTitle("Grower Orders")
            .refreshable { await viewModel.loadGardenerOrders() }
            .task { await viewModel.loadGardenerOrders() }
        }
    }
}
