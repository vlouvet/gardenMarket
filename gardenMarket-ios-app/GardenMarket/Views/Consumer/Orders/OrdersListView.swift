import SwiftUI

struct OrdersListView: View {
    @State private var viewModel = OrderViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.orders.isEmpty {
                    ProgressView()
                } else if viewModel.orders.isEmpty {
                    ContentUnavailableView("No Orders", systemImage: "bag", description: Text("Your orders will appear here."))
                } else {
                    List(viewModel.orders) { order in
                        NavigationLink(value: order.id) {
                            OrderRow(order: order)
                        }
                    }
                }
            }
            .navigationTitle("Orders")
            .navigationDestination(for: Int.self) { orderId in
                OrderDetailView(orderId: orderId)
            }
            .refreshable { await viewModel.loadOrders() }
            .task { await viewModel.loadOrders() }
        }
    }
}

struct OrderRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Order #\(order.id)")
                    .font(.headline)
                Spacer()
                StatusBadge(status: order.status)
            }
            if let date = order.createdAt {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("\(order.items?.count ?? 0) item(s)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(displayText)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var displayText: String {
        switch status {
        case "AWAITING_PICKUP_SCHEDULING": return "Awaiting"
        case "SCHEDULED": return "Scheduled"
        case "COMPLETE": return "Complete"
        case "CANCELLED": return "Cancelled"
        default: return status.capitalized
        }
    }

    private var color: Color {
        switch status {
        case "SCHEDULED": return .blue
        case "COMPLETE": return .green
        case "CANCELLED": return .red
        default: return .orange
        }
    }
}
