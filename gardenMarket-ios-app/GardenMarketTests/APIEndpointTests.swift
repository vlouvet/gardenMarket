import XCTest
@testable import GardenMarket

final class APIEndpointTests: XCTestCase {

    // MARK: - Paths

    func testLoginPath() {
        let ep = APIEndpoint.login(email: "a@b.com", password: "pass")
        XCTAssertEqual(ep.path, "/api/accounts/login/")
    }

    func testRegisterPath() {
        let ep = APIEndpoint.register(email: "a@b.com", password: "pass", role: "CONSUMER")
        XCTAssertEqual(ep.path, "/api/accounts/register/")
    }

    func testRefreshTokenPath() {
        let ep = APIEndpoint.refreshToken(token: "tok")
        XCTAssertEqual(ep.path, "/api/accounts/token/refresh/")
    }

    func testMePath() {
        XCTAssertEqual(APIEndpoint.me.path, "/api/accounts/me/")
    }

    func testProfilePath() {
        XCTAssertEqual(APIEndpoint.getProfile.path, "/api/accounts/profile/")
        let update = ProfileUpdate(addressLine1: "", addressLine2: "", city: "", state: "", postalCode: "", country: "")
        XCTAssertEqual(APIEndpoint.updateProfile(update).path, "/api/accounts/profile/")
    }

    func testUpgradePath() {
        XCTAssertEqual(APIEndpoint.upgrade.path, "/api/accounts/upgrade/")
    }

    func testOnboardingPath() {
        XCTAssertEqual(APIEndpoint.onboardingStatus.path, "/api/accounts/onboarding/")
    }

    func testListListingsPath() {
        XCTAssertEqual(APIEndpoint.listListings(nil).path, "/api/listings/")
    }

    func testGetListingPath() {
        XCTAssertEqual(APIEndpoint.getListing(id: 42).path, "/api/listings/42/")
    }

    func testCreateListingPath() {
        let req = CreateListingRequest(plant: 1, type: "PRODUCE", unit: "lb", price: "5.00", quantityAvailable: 10, pickupWindow: nil, pickupDays: nil)
        XCTAssertEqual(APIEndpoint.createListing(req).path, "/api/listings/")
    }

    func testUpdateListingPath() {
        let req = UpdateListingRequest()
        XCTAssertEqual(APIEndpoint.updateListing(id: 7, req).path, "/api/listings/7/")
    }

    func testPlantPaths() {
        XCTAssertEqual(APIEndpoint.listPlants.path, "/api/plants/")
        let req = CreatePlantRequest(gardener: 1, name: "Basil", species: "O. basilicum", description: "", tags: "", growMethod: "SOIL")
        XCTAssertEqual(APIEndpoint.createPlant(req).path, "/api/plants/")
        XCTAssertEqual(APIEndpoint.updatePlant(id: 3, req).path, "/api/plants/3/")
    }

    func testGardenerPaths() {
        XCTAssertEqual(APIEndpoint.listGardeners.path, "/api/gardeners/")
        XCTAssertEqual(APIEndpoint.getGardener(id: 5).path, "/api/gardeners/5/")
        let req = UpdateGardenerRequest()
        XCTAssertEqual(APIEndpoint.updateGardener(id: 5, req).path, "/api/gardeners/5/")
    }

    func testCartPaths() {
        XCTAssertEqual(APIEndpoint.getCart.path, "/api/cart/")
        XCTAssertEqual(APIEndpoint.addToCart(listingId: 1, quantity: 2).path, "/api/cart/")
        XCTAssertEqual(APIEndpoint.removeCartItem(id: 99).path, "/api/cart/99/")
    }

    func testOrderPaths() {
        XCTAssertEqual(APIEndpoint.listOrders.path, "/api/orders/")
        XCTAssertEqual(APIEndpoint.createOrder(centerId: 1, pickupWindow: "AM", pickupDate: nil).path, "/api/orders/")
        XCTAssertEqual(APIEndpoint.getOrder(id: 10).path, "/api/orders/10/")
        XCTAssertEqual(APIEndpoint.mockPay(orderId: 10).path, "/api/orders/10/mock_pay/")
        XCTAssertEqual(APIEndpoint.gardenerOrders.path, "/api/orders/gardener/")
    }

    func testCenterPath() {
        XCTAssertEqual(APIEndpoint.listCenters.path, "/api/centers/")
    }

    // MARK: - HTTP Methods

    func testPostMethods() {
        XCTAssertEqual(APIEndpoint.login(email: "", password: "").method, .post)
        XCTAssertEqual(APIEndpoint.register(email: "", password: "", role: "").method, .post)
        XCTAssertEqual(APIEndpoint.refreshToken(token: "").method, .post)
        XCTAssertEqual(APIEndpoint.upgrade.method, .post)
        let req = CreateListingRequest(plant: 1, type: "PRODUCE", unit: "lb", price: "5", quantityAvailable: 1, pickupWindow: nil, pickupDays: nil)
        XCTAssertEqual(APIEndpoint.createListing(req).method, .post)
        let plantReq = CreatePlantRequest(gardener: 1, name: "", species: "", description: "", tags: "", growMethod: "")
        XCTAssertEqual(APIEndpoint.createPlant(plantReq).method, .post)
        XCTAssertEqual(APIEndpoint.addToCart(listingId: 1, quantity: 1).method, .post)
        XCTAssertEqual(APIEndpoint.createOrder(centerId: 1, pickupWindow: "", pickupDate: nil).method, .post)
        XCTAssertEqual(APIEndpoint.mockPay(orderId: 1).method, .post)
    }

    func testPatchMethods() {
        let profileUpdate = ProfileUpdate(addressLine1: "", addressLine2: "", city: "", state: "", postalCode: "", country: "")
        XCTAssertEqual(APIEndpoint.updateProfile(profileUpdate).method, .patch)
        let listingReq = UpdateListingRequest()
        XCTAssertEqual(APIEndpoint.updateListing(id: 1, listingReq).method, .patch)
        let plantReq = CreatePlantRequest(gardener: 1, name: "", species: "", description: "", tags: "", growMethod: "")
        XCTAssertEqual(APIEndpoint.updatePlant(id: 1, plantReq).method, .patch)
        let gardenerReq = UpdateGardenerRequest()
        XCTAssertEqual(APIEndpoint.updateGardener(id: 1, gardenerReq).method, .patch)
    }

    func testDeleteMethod() {
        XCTAssertEqual(APIEndpoint.removeCartItem(id: 1).method, .delete)
    }

    func testGetMethods() {
        XCTAssertEqual(APIEndpoint.me.method, .get)
        XCTAssertEqual(APIEndpoint.getProfile.method, .get)
        XCTAssertEqual(APIEndpoint.onboardingStatus.method, .get)
        XCTAssertEqual(APIEndpoint.listListings(nil).method, .get)
        XCTAssertEqual(APIEndpoint.getListing(id: 1).method, .get)
        XCTAssertEqual(APIEndpoint.listPlants.method, .get)
        XCTAssertEqual(APIEndpoint.listGardeners.method, .get)
        XCTAssertEqual(APIEndpoint.getGardener(id: 1).method, .get)
        XCTAssertEqual(APIEndpoint.getCart.method, .get)
        XCTAssertEqual(APIEndpoint.listOrders.method, .get)
        XCTAssertEqual(APIEndpoint.getOrder(id: 1).method, .get)
        XCTAssertEqual(APIEndpoint.gardenerOrders.method, .get)
        XCTAssertEqual(APIEndpoint.listCenters.method, .get)
    }

    // MARK: - Auth requirements

    func testPublicEndpoints() {
        XCTAssertFalse(APIEndpoint.login(email: "", password: "").requiresAuth)
        XCTAssertFalse(APIEndpoint.register(email: "", password: "", role: "").requiresAuth)
        XCTAssertFalse(APIEndpoint.refreshToken(token: "").requiresAuth)
        XCTAssertFalse(APIEndpoint.listCenters.requiresAuth)
        XCTAssertFalse(APIEndpoint.listListings(nil).requiresAuth)
        XCTAssertFalse(APIEndpoint.getListing(id: 1).requiresAuth)
    }

    func testAuthenticatedEndpoints() {
        XCTAssertTrue(APIEndpoint.me.requiresAuth)
        XCTAssertTrue(APIEndpoint.getProfile.requiresAuth)
        XCTAssertTrue(APIEndpoint.upgrade.requiresAuth)
        XCTAssertTrue(APIEndpoint.getCart.requiresAuth)
        XCTAssertTrue(APIEndpoint.listOrders.requiresAuth)
        XCTAssertTrue(APIEndpoint.addToCart(listingId: 1, quantity: 1).requiresAuth)
    }

    // MARK: - Query Items

    func testListListingsWithNoFilterReturnsNilQueryItems() {
        XCTAssertNil(APIEndpoint.listListings(nil).queryItems)
    }

    func testListListingsWithFilterReturnsQueryItems() {
        let filter = ListingFilter(type: "PRODUCE", inStock: true)
        let items = APIEndpoint.listListings(filter).queryItems
        XCTAssertNotNil(items)
        XCTAssertEqual(items?.count, 2)
    }

    func testNonListingEndpointsReturnNilQueryItems() {
        XCTAssertNil(APIEndpoint.me.queryItems)
        XCTAssertNil(APIEndpoint.getCart.queryItems)
        XCTAssertNil(APIEndpoint.listOrders.queryItems)
    }

    // MARK: - Body

    func testLoginBody() throws {
        let ep = APIEndpoint.login(email: "test@example.com", password: "secret")
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(dict?["email"], "test@example.com")
        XCTAssertEqual(dict?["password"], "secret")
    }

    func testGetEndpointsHaveNoBody() {
        XCTAssertNil(APIEndpoint.me.body)
        XCTAssertNil(APIEndpoint.getProfile.body)
        XCTAssertNil(APIEndpoint.listListings(nil).body)
        XCTAssertNil(APIEndpoint.getCart.body)
        XCTAssertNil(APIEndpoint.listOrders.body)
    }

    func testCreateOrderBodyIncludesPickupDate() throws {
        let ep = APIEndpoint.createOrder(centerId: 5, pickupWindow: "Morning", pickupDate: "2026-04-01")
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(dict?["distribution_center"], "5")
        XCTAssertEqual(dict?["pickup_date"], "2026-04-01")
    }

    func testCreateOrderBodyOmitsNilPickupDate() throws {
        let ep = APIEndpoint.createOrder(centerId: 5, pickupWindow: "Morning", pickupDate: nil)
        let body = ep.body
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertNil(dict?["pickup_date"])
    }

    // MARK: - Additional Body Tests

    func testRegisterBody() throws {
        let ep = APIEndpoint.register(email: "new@test.com", password: "pass123", role: "GARDENER")
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(dict?["email"], "new@test.com")
        XCTAssertEqual(dict?["password"], "pass123")
        XCTAssertEqual(dict?["role"], "GARDENER")
    }

    func testRefreshTokenBody() throws {
        let ep = APIEndpoint.refreshToken(token: "my-refresh-token")
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: String]
        XCTAssertEqual(dict?["refresh"], "my-refresh-token")
    }

    func testUpdateProfileBody() throws {
        let update = ProfileUpdate(
            addressLine1: "123 Main St", addressLine2: "Apt 4",
            city: "Denver", state: "CO", postalCode: "80202", country: "US"
        )
        let ep = APIEndpoint.updateProfile(update)
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["addressLine1"] as? String, "123 Main St")
        XCTAssertEqual(dict?["addressLine2"] as? String, "Apt 4")
        XCTAssertEqual(dict?["city"] as? String, "Denver")
        XCTAssertEqual(dict?["state"] as? String, "CO")
        XCTAssertEqual(dict?["postalCode"] as? String, "80202")
        XCTAssertEqual(dict?["country"] as? String, "US")
    }

    func testCreateListingBody() throws {
        let req = CreateListingRequest(
            plant: 3, type: "SEEDS", unit: "each", price: "4.99",
            quantityAvailable: 50, pickupWindow: "Morning", pickupDays: ["MONDAY", "WEDNESDAY"]
        )
        let ep = APIEndpoint.createListing(req)
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["plant"] as? Int, 3)
        XCTAssertEqual(dict?["type"] as? String, "SEEDS")
        XCTAssertEqual(dict?["unit"] as? String, "each")
        XCTAssertEqual(dict?["price"] as? String, "4.99")
        XCTAssertEqual(dict?["quantityAvailable"] as? Int, 50)
        XCTAssertEqual(dict?["pickupWindow"] as? String, "Morning")
        XCTAssertEqual(dict?["pickupDays"] as? [String], ["MONDAY", "WEDNESDAY"])
    }

    func testUpdateListingBody() throws {
        var req = UpdateListingRequest()
        req.price = "6.99"
        req.status = "PAUSED"
        let ep = APIEndpoint.updateListing(id: 7, req)
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["price"] as? String, "6.99")
        XCTAssertEqual(dict?["status"] as? String, "PAUSED")
    }

    func testCreatePlantBody() throws {
        let req = CreatePlantRequest(
            gardener: 2, name: "Basil", species: "O. basilicum",
            description: "Sweet basil", tags: "herb,italian", growMethod: "SOIL"
        )
        let ep = APIEndpoint.createPlant(req)
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["gardener"] as? Int, 2)
        XCTAssertEqual(dict?["name"] as? String, "Basil")
        XCTAssertEqual(dict?["species"] as? String, "O. basilicum")
        XCTAssertEqual(dict?["growMethod"] as? String, "SOIL")
    }

    func testAddToCartBody() throws {
        let ep = APIEndpoint.addToCart(listingId: 42, quantity: 3)
        let body = ep.body
        XCTAssertNotNil(body)
        let data = try JSONEncoder().encode(AnyEncodableWrapper(body!))
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["listing"] as? Int, 42)
        XCTAssertEqual(dict?["quantity"] as? Int, 3)
    }

    func testDeleteAndMockPayHaveNoBody() {
        XCTAssertNil(APIEndpoint.removeCartItem(id: 1).body)
        XCTAssertNil(APIEndpoint.mockPay(orderId: 1).body)
    }
}

// Helper to encode `any Encodable` in tests
private struct AnyEncodableWrapper: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        self.encodeClosure = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
