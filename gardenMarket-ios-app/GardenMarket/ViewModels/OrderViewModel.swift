import Foundation
import Observation

@Observable
final class OrderViewModel {
    var orders: [Order] = []
    var isLoading = false
    var error: String?
    var orderCreated: Order?

    private let orderService = OrderService()
    private let centerService = CenterService()

    var centers: [DistributionCenter] = []

    func loadOrders() async {
        isLoading = true
        error = nil
        do {
            orders = try await orderService.getOrders()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadCenters() async {
        do {
            centers = try await centerService.getCenters()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createOrder(centerId: Int, pickupWindow: String, pickupDate: String? = nil) async {
        isLoading = true
        error = nil
        do {
            orderCreated = try await orderService.createOrder(
                centerId: centerId, pickupWindow: pickupWindow, pickupDate: pickupDate
            )
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func mockPay(orderId: Int) async {
        error = nil
        do {
            let updated = try await orderService.mockPay(orderId: orderId)
            if let idx = orders.firstIndex(where: { $0.id == orderId }) {
                orders[idx] = updated
            }
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadGardenerOrders() async {
        isLoading = true
        error = nil
        do {
            orders = try await orderService.getGardenerOrders()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
