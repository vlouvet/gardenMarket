import Foundation

struct OrderService {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func getOrders() async throws -> [Order] {
        try await client.request(.listOrders)
    }

    func createOrder(centerId: Int, pickupWindow: String, pickupDate: String? = nil) async throws -> Order {
        try await client.request(.createOrder(centerId: centerId, pickupWindow: pickupWindow, pickupDate: pickupDate))
    }

    func mockPay(orderId: Int) async throws -> Order {
        try await client.request(.mockPay(orderId: orderId))
    }

    func getGardenerOrders() async throws -> [Order] {
        try await client.request(.gardenerOrders)
    }
}
