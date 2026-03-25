import XCTest
@testable import GardenMarket

final class KeychainServiceTests: XCTestCase {
    private let keychain = KeychainService.shared

    override func setUp() {
        super.setUp()
        keychain.clearAll()
    }

    override func tearDown() {
        keychain.clearAll()
        super.tearDown()
    }

    func testAccessTokenInitiallyNil() {
        XCTAssertNil(keychain.accessToken)
    }

    func testRefreshTokenInitiallyNil() {
        XCTAssertNil(keychain.refreshToken)
    }

    func testSaveAndLoadAccessToken() {
        keychain.accessToken = "test-access-123"
        XCTAssertEqual(keychain.accessToken, "test-access-123")
    }

    func testSaveAndLoadRefreshToken() {
        keychain.refreshToken = "test-refresh-456"
        XCTAssertEqual(keychain.refreshToken, "test-refresh-456")
    }

    func testOverwriteAccessToken() {
        keychain.accessToken = "first"
        keychain.accessToken = "second"
        XCTAssertEqual(keychain.accessToken, "second")
    }

    func testSetNilDeletesAccessToken() {
        keychain.accessToken = "to-delete"
        keychain.accessToken = nil
        XCTAssertNil(keychain.accessToken)
    }

    func testSetNilDeletesRefreshToken() {
        keychain.refreshToken = "to-delete"
        keychain.refreshToken = nil
        XCTAssertNil(keychain.refreshToken)
    }

    func testClearAllRemovesBothTokens() {
        keychain.accessToken = "access"
        keychain.refreshToken = "refresh"
        keychain.clearAll()
        XCTAssertNil(keychain.accessToken)
        XCTAssertNil(keychain.refreshToken)
    }

    func testTokensAreIndependent() {
        keychain.accessToken = "access-only"
        XCTAssertNil(keychain.refreshToken)

        keychain.refreshToken = "refresh-only"
        XCTAssertEqual(keychain.accessToken, "access-only")
        XCTAssertEqual(keychain.refreshToken, "refresh-only")
    }

    func testEmptyStringToken() {
        keychain.accessToken = ""
        XCTAssertEqual(keychain.accessToken, "")
    }

    func testLongToken() {
        let longToken = String(repeating: "a", count: 2048)
        keychain.accessToken = longToken
        XCTAssertEqual(keychain.accessToken, longToken)
    }

    func testSpecialCharactersInToken() {
        let token = "eyJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIn0.abc+def/ghi="
        keychain.accessToken = token
        XCTAssertEqual(keychain.accessToken, token)
    }
}
