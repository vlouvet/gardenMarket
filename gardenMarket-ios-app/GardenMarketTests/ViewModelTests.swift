import XCTest
@testable import GardenMarket

// MARK: - AuthViewModel

final class AuthViewModelTests: XCTestCase {
    func testInitialState() {
        // Clear keychain first to ensure clean state
        KeychainService.shared.clearAll()
        let vm = AuthViewModel()
        XCTAssertNil(vm.currentUser)
        XCTAssertFalse(vm.isAuthenticated)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }

    func testLogoutClearsState() {
        KeychainService.shared.clearAll()
        let vm = AuthViewModel()
        // Simulate authenticated state
        vm.currentUser = User(id: 1, email: "a@b.com", role: "CONSUMER")
        vm.isAuthenticated = true

        vm.logout()

        XCTAssertNil(vm.currentUser)
        XCTAssertFalse(vm.isAuthenticated)
    }

    func testLogoutClearsKeychain() {
        let keychain = KeychainService.shared
        keychain.accessToken = "test-token"
        keychain.refreshToken = "test-refresh"

        let vm = AuthViewModel()
        vm.logout()

        XCTAssertNil(keychain.accessToken)
        XCTAssertNil(keychain.refreshToken)
    }

    func testInitWithExistingTokenSetsAuthenticated() {
        let keychain = KeychainService.shared
        keychain.accessToken = "existing-token"

        let vm = AuthViewModel()
        XCTAssertTrue(vm.isAuthenticated)

        // Clean up
        keychain.clearAll()
    }
}

// MARK: - ListingsViewModel

final class ListingsViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = ListingsViewModel()
        XCTAssertTrue(vm.listings.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }

    func testFilterDefaultsToEmpty() {
        let vm = ListingsViewModel()
        XCTAssertNil(vm.filter.type)
        XCTAssertNil(vm.filter.growMethod)
        XCTAssertNil(vm.filter.inStock)
        XCTAssertNil(vm.filter.address)
    }

    func testFilterCanBeUpdated() {
        let vm = ListingsViewModel()
        vm.filter.type = "PRODUCE"
        vm.filter.inStock = true
        XCTAssertEqual(vm.filter.type, "PRODUCE")
        XCTAssertEqual(vm.filter.inStock, true)
        XCTAssertEqual(vm.filter.queryItems.count, 2)
    }
}

// MARK: - CartViewModel

final class CartViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = CartViewModel()
        XCTAssertNil(vm.cart)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }

    func testItemCountWithNoCart() {
        let vm = CartViewModel()
        XCTAssertEqual(vm.itemCount, 0)
    }
}

// MARK: - OrderViewModel

final class OrderViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = OrderViewModel()
        XCTAssertTrue(vm.orders.isEmpty)
        XCTAssertTrue(vm.centers.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
        XCTAssertNil(vm.orderCreated)
    }
}

// MARK: - ProfileViewModel

final class ProfileViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = ProfileViewModel()
        XCTAssertNil(vm.profile)
        XCTAssertNil(vm.onboarding)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
        XCTAssertNil(vm.successMessage)
    }
}

// MARK: - GrowerDashboardViewModel

final class GrowerDashboardViewModelTests: XCTestCase {
    func testInitialState() {
        let vm = GrowerDashboardViewModel()
        XCTAssertTrue(vm.plants.isEmpty)
        XCTAssertTrue(vm.listings.isEmpty)
        XCTAssertTrue(vm.orders.isEmpty)
        XCTAssertNil(vm.gardenerProfile)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.error)
    }
}

// MARK: - Additional ViewModel Tests

final class CartViewModelAdditionalTests: XCTestCase {
    func testItemCountWithItems() {
        let vm = CartViewModel()
        let cart = Cart(id: 1, items: [
            CartItem(id: 1, listing: 5, quantity: 2),
            CartItem(id: 2, listing: 6, quantity: 1),
            CartItem(id: 3, listing: 7, quantity: 4),
        ])
        vm.cart = cart
        XCTAssertEqual(vm.itemCount, 3)
    }

    func testItemCountAfterClear() {
        let vm = CartViewModel()
        vm.cart = Cart(id: 1, items: [CartItem(id: 1, listing: 5, quantity: 2)])
        XCTAssertEqual(vm.itemCount, 1)
        vm.cart = nil
        XCTAssertEqual(vm.itemCount, 0)
    }
}

final class ListingsViewModelAdditionalTests: XCTestCase {
    func testFilterQueryItemsReflectMultipleFields() {
        let vm = ListingsViewModel()
        vm.filter.type = "SEEDS"
        vm.filter.growMethod = "ORGANIC"
        vm.filter.inStock = true
        vm.filter.address = "Boulder"
        XCTAssertEqual(vm.filter.queryItems.count, 4)
    }
}
