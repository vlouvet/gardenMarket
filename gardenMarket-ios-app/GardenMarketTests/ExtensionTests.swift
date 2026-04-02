import XCTest
import SwiftUI
@testable import GardenMarket

final class DecimalCurrencyTests: XCTestCase {
    func testCurrencyFormattedPositiveValue() {
        let value = Decimal(string: "19.99")!
        let formatted = value.currencyFormatted
        // Should contain the value — locale-dependent format
        XCTAssertTrue(formatted.contains("19.99") || formatted.contains("19,99"))
    }

    func testCurrencyFormattedZero() {
        let value = Decimal(0)
        let formatted = value.currencyFormatted
        XCTAssertTrue(formatted.contains("0"))
    }

    func testCurrencyFormattedLargeValue() {
        let value = Decimal(string: "1234.56")!
        let formatted = value.currencyFormatted
        XCTAssertTrue(formatted.contains("1") && formatted.contains("234"))
    }

    func testCurrencyFormattedNegativeValue() {
        let value = Decimal(string: "-5.00")!
        let formatted = value.currencyFormatted
        XCTAssertTrue(formatted.contains("5"))
    }

    func testCurrencyFormattedWholeNumber() {
        let value = Decimal(10)
        let formatted = value.currencyFormatted
        XCTAssertTrue(formatted.contains("10"))
    }
}

final class ColorThemeTests: XCTestCase {
    func testGardenAccentColorExists() {
        let color = Color.gardenAccent
        XCTAssertNotNil(color)
    }

    func testGardenSecondaryColorExists() {
        let color = Color.gardenSecondary
        XCTAssertNotNil(color)
    }

    func testGardenBackgroundColorExists() {
        let color = Color.gardenBackground
        XCTAssertNotNil(color)
    }
}
