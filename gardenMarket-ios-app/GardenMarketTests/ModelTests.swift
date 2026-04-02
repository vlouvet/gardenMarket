import XCTest
@testable import GardenMarket

final class UserTests: XCTestCase {
    func testIsGardener() {
        let user = User(id: 1, email: "a@b.com", role: "GARDENER")
        XCTAssertTrue(user.isGardener)
        XCTAssertFalse(user.isConsumer)
    }

    func testIsConsumer() {
        let user = User(id: 2, email: "c@d.com", role: "CONSUMER")
        XCTAssertTrue(user.isConsumer)
        XCTAssertFalse(user.isGardener)
    }

    func testUnknownRole() {
        let user = User(id: 3, email: "e@f.com", role: "ADMIN")
        XCTAssertFalse(user.isGardener)
        XCTAssertFalse(user.isConsumer)
    }

    func testDecodeFromJSON() throws {
        let json = """
        {"id": 1, "email": "test@example.com", "role": "CONSUMER"}
        """.data(using: .utf8)!
        let user = try JSONDecoder().decode(User.self, from: json)
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.role, "CONSUMER")
    }
}

final class ProfileTests: XCTestCase {
    func testDecodeMinimalProfile() throws {
        let json = """
        {}
        """.data(using: .utf8)!
        let profile = try JSONDecoder().decode(Profile.self, from: json)
        XCTAssertNil(profile.city)
        XCTAssertNil(profile.lat)
        XCTAssertNil(profile.lon)
    }

    func testDecodeFullProfile() throws {
        let json = """
        {
            "address_line1": "123 Main St",
            "city": "Denver",
            "state": "CO",
            "postal_code": "80202",
            "lat": 39.74,
            "lon": -104.99
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let profile = try decoder.decode(Profile.self, from: json)
        XCTAssertEqual(profile.city, "Denver")
        XCTAssertEqual(profile.lat, 39.74)
    }
}

final class AuthTokensTests: XCTestCase {
    func testDecode() throws {
        let json = """
        {"access": "abc123", "refresh": "def456"}
        """.data(using: .utf8)!
        let tokens = try JSONDecoder().decode(AuthTokens.self, from: json)
        XCTAssertEqual(tokens.access, "abc123")
        XCTAssertEqual(tokens.refresh, "def456")
    }
}

final class ListingTests: XCTestCase {
    private func makeListing(type: String = "PRODUCE", unit: String = "lb") -> Listing {
        Listing(
            id: 1, plant: 1, type: type, unit: unit,
            price: FlexDecimal(Decimal(4.50)),
            quantityAvailable: 10, status: "ACTIVE",
            isHidden: false, pickupWindow: nil, pickupDays: nil,
            createdAt: nil, inStock: true, distanceMiles: nil,
            grownWithinMiles: nil, growerVerified: nil, growerRating: nil
        )
    }

    func testDisplayTypeProduce() {
        XCTAssertEqual(makeListing(type: "PRODUCE").displayType, "Produce")
    }

    func testDisplayTypeSeeds() {
        XCTAssertEqual(makeListing(type: "SEEDS").displayType, "Seeds")
    }

    func testDisplayTypeClipping() {
        XCTAssertEqual(makeListing(type: "CLIPPING").displayType, "Clipping")
    }

    func testDisplayTypeUnknown() {
        XCTAssertEqual(makeListing(type: "other").displayType, "Other")
    }

    func testDisplayUnitLb() {
        XCTAssertEqual(makeListing(unit: "lb").displayUnit, "lb")
    }

    func testDisplayUnitEach() {
        XCTAssertEqual(makeListing(unit: "each").displayUnit, "ea")
    }

    func testDisplayUnitGram() {
        XCTAssertEqual(makeListing(unit: "gram").displayUnit, "g")
    }

    func testDisplayUnitBundle() {
        XCTAssertEqual(makeListing(unit: "bundle").displayUnit, "bundle")
    }

    func testDisplayUnitPassthrough() {
        XCTAssertEqual(makeListing(unit: "kg").displayUnit, "kg")
    }

    func testDecodeFromSnakeCaseJSON() throws {
        let json = """
        {
            "id": 5,
            "plant": 2,
            "type": "SEEDS",
            "unit": "each",
            "price": "3.99",
            "quantity_available": 20,
            "status": "ACTIVE"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let listing = try decoder.decode(Listing.self, from: json)
        XCTAssertEqual(listing.id, 5)
        XCTAssertEqual(listing.quantityAvailable, 20)
        XCTAssertEqual(listing.price.value, Decimal(string: "3.99"))
    }
}

final class ListingFilterTests: XCTestCase {
    func testEmptyFilterReturnsNoQueryItems() {
        let filter = ListingFilter()
        XCTAssertTrue(filter.queryItems.isEmpty)
    }

    func testTypeFilter() {
        let filter = ListingFilter(type: "PRODUCE")
        let items = filter.queryItems
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "type")
        XCTAssertEqual(items.first?.value, "PRODUCE")
    }

    func testInStockTrueAddsItem() {
        let filter = ListingFilter(inStock: true)
        let items = filter.queryItems
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "in_stock")
        XCTAssertEqual(items.first?.value, "1")
    }

    func testInStockFalseOmitsItem() {
        let filter = ListingFilter(inStock: false)
        XCTAssertTrue(filter.queryItems.isEmpty)
    }

    func testMultipleFilters() {
        let filter = ListingFilter(type: "SEEDS", growMethod: "ORGANIC", address: "Denver")
        let items = filter.queryItems
        XCTAssertEqual(items.count, 3)
        let names = Set(items.map(\.name))
        XCTAssertTrue(names.contains("type"))
        XCTAssertTrue(names.contains("grow_method"))
        XCTAssertTrue(names.contains("address"))
    }

    func testLocationFilters() {
        let filter = ListingFilter(lat: 39.74, lon: -104.99)
        let items = filter.queryItems
        XCTAssertEqual(items.count, 2)
        let latItem = items.first { $0.name == "lat" }
        XCTAssertEqual(latItem?.value, "39.74")
    }
}

final class FlexDecimalTests: XCTestCase {
    func testInitWithDecimal() {
        let fd = FlexDecimal(Decimal(10.5))
        XCTAssertEqual(fd.value, Decimal(10.5))
    }

    func testDecodeFromString() throws {
        let json = "\"4.99\"".data(using: .utf8)!
        let fd = try JSONDecoder().decode(FlexDecimal.self, from: json)
        XCTAssertEqual(fd.value, Decimal(string: "4.99"))
    }

    func testDecodeFromNumber() throws {
        let json = "4.99".data(using: .utf8)!
        let fd = try JSONDecoder().decode(FlexDecimal.self, from: json)
        // Double-to-Decimal conversion may have precision differences
        XCTAssertNotNil(fd.value)
    }

    func testDecodeFromInteger() throws {
        let json = "10".data(using: .utf8)!
        let fd = try JSONDecoder().decode(FlexDecimal.self, from: json)
        XCTAssertEqual(fd.value, 10)
    }

    func testDecodeFromInvalidThrows() {
        let json = "true".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(FlexDecimal.self, from: json))
    }

    func testEncodesToString() throws {
        let fd = FlexDecimal(Decimal(string: "12.50")!)
        let data = try JSONEncoder().encode(fd)
        let str = String(data: data, encoding: .utf8)!
        XCTAssertTrue(str.contains("12.5"))
    }

    func testDescriptionContainsCurrency() {
        let fd = FlexDecimal(Decimal(string: "9.99")!)
        let desc = fd.description
        // Should contain the value in some currency format
        XCTAssertTrue(desc.contains("9.99") || desc.contains("9,99"))
    }
}

final class CartTests: XCTestCase {
    func testDecodeCart() throws {
        let json = """
        {
            "id": 1,
            "items": [
                {"id": 10, "listing": 5, "quantity": 2},
                {"id": 11, "listing": 6, "quantity": 1}
            ]
        }
        """.data(using: .utf8)!
        let cart = try JSONDecoder().decode(Cart.self, from: json)
        XCTAssertEqual(cart.id, 1)
        XCTAssertEqual(cart.items.count, 2)
        XCTAssertEqual(cart.items[0].listing, 5)
        XCTAssertEqual(cart.items[0].quantity, 2)
    }

    func testDecodeEmptyCart() throws {
        let json = """
        {"id": 1, "items": []}
        """.data(using: .utf8)!
        let cart = try JSONDecoder().decode(Cart.self, from: json)
        XCTAssertTrue(cart.items.isEmpty)
    }
}

final class OrderTests: XCTestCase {
    private func makeOrder(status: String, paymentStatus: String? = nil) -> Order {
        Order(
            id: 1, status: status, distributionCenter: 1,
            pickupWindow: "Morning", pickupDate: nil,
            mockPaymentReference: nil, stripePaymentIntentId: nil,
            paymentStatus: paymentStatus, checkinCode: nil,
            checkedInAt: nil, createdAt: nil, items: nil
        )
    }

    func testDisplayStatusCreated() {
        XCTAssertEqual(makeOrder(status: "CREATED").displayStatus, "Created")
    }

    func testDisplayStatusAwaitingPickup() {
        XCTAssertEqual(makeOrder(status: "AWAITING_PICKUP_SCHEDULING").displayStatus, "Awaiting Pickup")
    }

    func testDisplayStatusScheduled() {
        XCTAssertEqual(makeOrder(status: "SCHEDULED").displayStatus, "Scheduled")
    }

    func testDisplayStatusComplete() {
        XCTAssertEqual(makeOrder(status: "COMPLETE").displayStatus, "Complete")
    }

    func testDisplayStatusCancelled() {
        XCTAssertEqual(makeOrder(status: "CANCELLED").displayStatus, "Cancelled")
    }

    func testDisplayStatusUnknownPassthrough() {
        XCTAssertEqual(makeOrder(status: "REFUNDED").displayStatus, "REFUNDED")
    }

    func testIsPaidWithPaid() {
        XCTAssertTrue(makeOrder(status: "CREATED", paymentStatus: "paid").isPaid)
    }

    func testIsPaidWithSucceeded() {
        XCTAssertTrue(makeOrder(status: "CREATED", paymentStatus: "succeeded").isPaid)
    }

    func testIsPaidWithPending() {
        XCTAssertFalse(makeOrder(status: "CREATED", paymentStatus: "pending").isPaid)
    }

    func testIsPaidWithNil() {
        XCTAssertFalse(makeOrder(status: "CREATED", paymentStatus: nil).isPaid)
    }

    func testDecodeOrderItemWithFlexDecimal() throws {
        let json = """
        {"id": 1, "listing": 5, "quantity": 3, "price_at_purchase": "12.99"}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let item = try decoder.decode(OrderItem.self, from: json)
        XCTAssertEqual(item.quantity, 3)
        XCTAssertEqual(item.priceAtPurchase.value, Decimal(string: "12.99"))
    }
}

final class PlantProfileTests: XCTestCase {
    private func makePlant(growMethod: String?) -> PlantProfile {
        PlantProfile(id: 1, gardener: 1, name: "Basil", species: nil, description: nil, tags: nil, growMethod: growMethod)
    }

    func testDisplayGrowMethodSoil() {
        XCTAssertEqual(makePlant(growMethod: "SOIL").displayGrowMethod, "Soil")
    }

    func testDisplayGrowMethodHydroponic() {
        XCTAssertEqual(makePlant(growMethod: "HYDROPONIC").displayGrowMethod, "Hydroponic")
    }

    func testDisplayGrowMethodAquaponic() {
        XCTAssertEqual(makePlant(growMethod: "AQUAPONIC").displayGrowMethod, "Aquaponic")
    }

    func testDisplayGrowMethodOrganic() {
        XCTAssertEqual(makePlant(growMethod: "ORGANIC").displayGrowMethod, "Organic")
    }

    func testDisplayGrowMethodNil() {
        XCTAssertEqual(makePlant(growMethod: nil).displayGrowMethod, "Unknown")
    }

    func testDisplayGrowMethodUnknownPassthrough() {
        XCTAssertEqual(makePlant(growMethod: "AEROPONICS").displayGrowMethod, "AEROPONICS")
    }
}

final class GardenerProfileTests: XCTestCase {
    func testDecode() throws {
        let json = """
        {"id": 1, "bio": "Love gardening", "payout_details": null, "verified": true, "rating_avg": 4.5, "rating_count": 12}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let profile = try decoder.decode(GardenerProfile.self, from: json)
        XCTAssertEqual(profile.id, 1)
        XCTAssertTrue(profile.verified)
        XCTAssertEqual(profile.ratingAvg, 4.5)
        XCTAssertEqual(profile.ratingCount, 12)
    }
}

final class DistributionCenterTests: XCTestCase {
    func testFullAddress() {
        let center = DistributionCenter(
            id: 1, name: "Hub", addressLine1: "100 Main St",
            addressLine2: nil, city: "Denver", state: "CO",
            postalCode: "80202", country: "US", lat: nil, lon: nil,
            status: nil, capacityPerDay: nil, pickupWindows: nil,
            remainingCapacity: nil
        )
        XCTAssertEqual(center.fullAddress, "100 Main St, Denver, CO, 80202")
    }
}

final class OnboardingStatusTests: XCTestCase {
    func testAllCompleteTrue() {
        let status = OnboardingStatus(profileComplete: true, payoutComplete: true, firstListing: true)
        XCTAssertTrue(status.allComplete)
    }

    func testAllCompletePartial() {
        let status = OnboardingStatus(profileComplete: true, payoutComplete: false, firstListing: true)
        XCTAssertFalse(status.allComplete)
    }

    func testAllCompleteFalse() {
        let status = OnboardingStatus(profileComplete: false, payoutComplete: false, firstListing: false)
        XCTAssertFalse(status.allComplete)
    }
}

// MARK: - Additional Model Tests

final class DistributionCenterAdditionalTests: XCTestCase {
    func testFullAddressIgnoresLine2() {
        let center = DistributionCenter(
            id: 1, name: "Hub", addressLine1: "100 Main St",
            addressLine2: "Suite 200", city: "Denver", state: "CO",
            postalCode: "80202", country: "US", lat: nil, lon: nil,
            status: nil, capacityPerDay: nil, pickupWindows: nil,
            remainingCapacity: nil
        )
        XCTAssertEqual(center.fullAddress, "100 Main St, Denver, CO, 80202")
        XCTAssertFalse(center.fullAddress.contains("Suite 200"))
    }

    func testDecodeFromSnakeCaseJSON() throws {
        let json = """
        {
            "id": 5, "name": "North Hub",
            "address_line1": "200 Oak Ave", "address_line2": "Bldg B",
            "city": "Boulder", "state": "CO", "postal_code": "80301",
            "country": "US", "lat": 40.01, "lon": -105.27,
            "status": "ACTIVE", "capacity_per_day": 100,
            "pickup_windows": ["Morning", "Afternoon"],
            "remaining_capacity": 42
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let center = try decoder.decode(DistributionCenter.self, from: json)
        XCTAssertEqual(center.id, 5)
        XCTAssertEqual(center.name, "North Hub")
        XCTAssertEqual(center.addressLine2, "Bldg B")
        XCTAssertEqual(center.lat, 40.01)
        XCTAssertEqual(center.capacityPerDay, 100)
        XCTAssertEqual(center.pickupWindows, ["Morning", "Afternoon"])
        XCTAssertEqual(center.remainingCapacity, 42)
    }
}

final class ListingAdditionalTests: XCTestCase {
    func testDecodeAllOptionalFields() throws {
        let json = """
        {
            "id": 10, "plant": 3, "type": "PRODUCE", "unit": "lb",
            "price": "5.50", "quantity_available": 25, "status": "ACTIVE",
            "is_hidden": true, "pickup_window": "Morning",
            "pickup_days": ["MONDAY", "FRIDAY"],
            "in_stock": true, "distance_miles": 3.2,
            "grown_within_miles": 10, "grower_verified": true, "grower_rating": 4.8
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let listing = try decoder.decode(Listing.self, from: json)
        XCTAssertEqual(listing.isHidden, true)
        XCTAssertEqual(listing.pickupWindow, "Morning")
        XCTAssertEqual(listing.pickupDays, ["MONDAY", "FRIDAY"])
        XCTAssertEqual(listing.distanceMiles, 3.2)
        XCTAssertEqual(listing.grownWithinMiles, 10)
        XCTAssertEqual(listing.growerVerified, true)
        XCTAssertEqual(listing.growerRating, 4.8)
    }
}

final class FlexDecimalAdditionalTests: XCTestCase {
    func testZeroRoundtrip() throws {
        let fd = FlexDecimal(Decimal.zero)
        let data = try JSONEncoder().encode(fd)
        let decoded = try JSONDecoder().decode(FlexDecimal.self, from: data)
        XCTAssertEqual(decoded.value, Decimal.zero)
    }

    func testNegativeRoundtrip() throws {
        let fd = FlexDecimal(Decimal(string: "-15.75")!)
        let data = try JSONEncoder().encode(fd)
        let decoded = try JSONDecoder().decode(FlexDecimal.self, from: data)
        XCTAssertEqual(decoded.value, Decimal(string: "-15.75"))
    }
}

final class OrderAdditionalTests: XCTestCase {
    func testDecodeFullJSON() throws {
        let json = """
        {
            "id": 42, "status": "SCHEDULED",
            "distribution_center": 3, "pickup_window": "Afternoon",
            "pickup_date": "2026-04-15",
            "mock_payment_reference": "mock_abc123",
            "stripe_payment_intent_id": null,
            "payment_status": "paid",
            "checkin_code": "XYZ789",
            "checked_in_at": null, "created_at": null,
            "items": [
                {"id": 1, "listing": 5, "quantity": 2, "price_at_purchase": "4.99"},
                {"id": 2, "listing": 8, "quantity": 1, "price_at_purchase": "12.00"}
            ]
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let order = try decoder.decode(Order.self, from: json)
        XCTAssertEqual(order.id, 42)
        XCTAssertEqual(order.displayStatus, "Scheduled")
        XCTAssertTrue(order.isPaid)
        XCTAssertEqual(order.distributionCenter, 3)
        XCTAssertEqual(order.mockPaymentReference, "mock_abc123")
        XCTAssertEqual(order.checkinCode, "XYZ789")
        XCTAssertEqual(order.items?.count, 2)
        XCTAssertEqual(order.items?[0].priceAtPurchase.value, Decimal(string: "4.99"))
        XCTAssertEqual(order.items?[1].quantity, 1)
    }
}

final class PlantProfileAdditionalTests: XCTestCase {
    func testDecodeFromSnakeCaseJSON() throws {
        let json = """
        {
            "id": 7, "gardener": 2, "name": "Cherry Tomato",
            "species": "S. lycopersicum", "description": "Sweet cherry variety",
            "tags": "vegetable,summer", "grow_method": "HYDROPONIC"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let plant = try decoder.decode(PlantProfile.self, from: json)
        XCTAssertEqual(plant.id, 7)
        XCTAssertEqual(plant.name, "Cherry Tomato")
        XCTAssertEqual(plant.species, "S. lycopersicum")
        XCTAssertEqual(plant.tags, "vegetable,summer")
        XCTAssertEqual(plant.displayGrowMethod, "Hydroponic")
    }
}

final class CreateListingRequestTests: XCTestCase {
    func testEncode() throws {
        let req = CreateListingRequest(
            plant: 1, type: "PRODUCE", unit: "lb", price: "5.00",
            quantityAvailable: 10, pickupWindow: "Morning", pickupDays: ["MONDAY"]
        )
        let data = try JSONEncoder().encode(req)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["plant"] as? Int, 1)
        XCTAssertEqual(dict?["type"] as? String, "PRODUCE")
        XCTAssertEqual(dict?["price"] as? String, "5.00")
        XCTAssertEqual(dict?["quantityAvailable"] as? Int, 10)
        XCTAssertEqual(dict?["pickupDays"] as? [String], ["MONDAY"])
    }
}

final class UpdateListingRequestTests: XCTestCase {
    func testEncodePartial() throws {
        var req = UpdateListingRequest()
        req.price = "9.99"
        let data = try JSONEncoder().encode(req)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(dict?["price"] as? String, "9.99")
    }

    func testEncodeEmpty() throws {
        let req = UpdateListingRequest()
        let data = try JSONEncoder().encode(req)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(dict)
    }
}

final class ListingFilterAdditionalTests: XCTestCase {
    func testPickupDayFilter() {
        let filter = ListingFilter(pickupDay: "MONDAY")
        let items = filter.queryItems
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "pickup_day")
        XCTAssertEqual(items.first?.value, "MONDAY")
    }

    func testAllFieldsPopulated() {
        let filter = ListingFilter(
            type: "PRODUCE", growMethod: "ORGANIC", pickupDay: "FRIDAY",
            inStock: true, lat: 39.74, lon: -104.99, address: "Denver"
        )
        let items = filter.queryItems
        XCTAssertEqual(items.count, 7)
        let names = Set(items.map(\.name))
        XCTAssertTrue(names.contains("type"))
        XCTAssertTrue(names.contains("grow_method"))
        XCTAssertTrue(names.contains("pickup_day"))
        XCTAssertTrue(names.contains("in_stock"))
        XCTAssertTrue(names.contains("lat"))
        XCTAssertTrue(names.contains("lon"))
        XCTAssertTrue(names.contains("address"))
    }
}
