import SwiftUI

struct OrderDetailView: View {
    let orderId: Int
    @State private var order: Order?
    @State private var isLoading = true
    @State private var error: String?

    private let orderService = OrderService()

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let order {
                List {
                    Section("Status") {
                        HStack {
                            Text("Status")
                            Spacer()
                            StatusBadge(status: order.status)
                        }
                        if let payment = order.paymentStatus {
                            HStack {
                                Text("Payment")
                                Spacer()
                                Text(payment.capitalized)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if let date = order.createdAt {
                            HStack {
                                Text("Created")
                                Spacer()
                                Text(date, style: .date)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if let items = order.items, !items.isEmpty {
                        Section("Items") {
                            ForEach(items) { item in
                                HStack {
                                    Text("Listing #\(item.listing)")
                                    Spacer()
                                    Text("x\(item.quantity)")
                                    Text(item.priceAtPurchase.description)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    if let window = order.pickupWindow, !window.isEmpty {
                        Section("Pickup") {
                            Text(window)
                            if let date = order.pickupDate {
                                Text("Date: \(date)")
                            }
                        }
                    }

                    if let code = order.checkinCode, !code.isEmpty {
                        Section("Check-in Code") {
                            Text(code)
                                .font(.title3.monospaced())
                                .textSelection(.enabled)
                        }
                    }

                    if order.status == "AWAITING_PICKUP_SCHEDULING" && !order.isPaid {
                        Section {
                            Button {
                                Task {
                                    do {
                                        self.order = try await orderService.mockPay(orderId: order.id)
                                    } catch let err as APIError {
                                        error = err.errorDescription
                                    } catch {
                                        self.error = error.localizedDescription
                                    }
                                }
                            } label: {
                                Label("Pay (Mock)", systemImage: "creditcard")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    if let error {
                        Section {
                            Text(error).foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Order #\(orderId)")
        .task {
            do {
                order = try await orderService.getOrders().first(where: { $0.id == orderId })
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}
