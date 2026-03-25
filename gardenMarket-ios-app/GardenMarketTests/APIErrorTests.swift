import XCTest
@testable import GardenMarket

final class APIErrorTests: XCTestCase {

    // MARK: - Error descriptions

    func testUnauthorizedDescription() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.errorDescription, "Session expired. Please log in again.")
    }

    func testNetworkErrorDescription() {
        let error = APIError.networkError("timeout")
        XCTAssertEqual(error.errorDescription, "Network error: timeout")
    }

    func testServerErrorDescription() {
        let error = APIError.serverError(500, "Internal Server Error")
        XCTAssertEqual(error.errorDescription, "Server error (500): Internal Server Error")
    }

    func testDecodingErrorDescription() {
        let error = APIError.decodingError("missing field")
        XCTAssertEqual(error.errorDescription, "Data error: missing field")
    }

    func testInvalidURLDescription() {
        let error = APIError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid server URL.")
    }

    func testNoDataDescription() {
        let error = APIError.noData
        XCTAssertEqual(error.errorDescription, "No data received.")
    }

    // MARK: - Equatable

    func testEqualUnauthorized() {
        XCTAssertEqual(APIError.unauthorized, APIError.unauthorized)
    }

    func testEqualNetworkError() {
        XCTAssertEqual(APIError.networkError("x"), APIError.networkError("x"))
    }

    func testNotEqualDifferentNetworkMessages() {
        XCTAssertNotEqual(APIError.networkError("a"), APIError.networkError("b"))
    }

    func testEqualServerError() {
        XCTAssertEqual(APIError.serverError(404, "Not found"), APIError.serverError(404, "Not found"))
    }

    func testNotEqualDifferentCases() {
        XCTAssertNotEqual(APIError.unauthorized, APIError.invalidURL)
    }

    func testNotEqualDifferentServerCodes() {
        XCTAssertNotEqual(APIError.serverError(400, "Bad"), APIError.serverError(500, "Bad"))
    }

    // MARK: - LocalizedError conformance

    func testConformsToLocalizedError() {
        let error: LocalizedError = APIError.unauthorized
        XCTAssertNotNil(error.errorDescription)
    }

    func testConformsToError() {
        let error: Error = APIError.networkError("fail")
        XCTAssertFalse(error.localizedDescription.isEmpty)
    }
}
