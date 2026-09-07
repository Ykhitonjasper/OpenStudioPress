import XCTest
@testable import OpenStudioPress

final class DecodeRouteTests: XCTestCase {
    func testSheetDecodes() {
        let link = "https://example.test/go"
        let route = AppSession.decodePayload(AppConfig.encodeSheet(link))
        XCTAssertEqual(route?.url, link)
        XCTAssertEqual(route?.enabled, true)
    }

    func testPlainLinkIsIgnored() {
        XCTAssertNil(AppSession.decodePayload(Data("https://example.test/go".utf8)))
    }

    func testQuotedJSONStringIsIgnored() {
        XCTAssertNil(AppSession.decodePayload(Data("\"https://example.test/go?ref=abc\"".utf8)))
    }

    func testSheetKeepsQuery() {
        let raw = "https://example.test/v3/route/?ref=6a918336a256a10001818e1b&p=p1ee"
        XCTAssertEqual(AppSession.decodePayload(AppConfig.encodeSheet(raw))?.url, raw)
    }

    func testSheetAllowsTrailingNewline() {
        let link = "https://example.test/go"
        var plate = AppConfig.encodeSheet(link)
        plate.append(contentsOf: "\n".utf8)
        XCTAssertEqual(AppSession.decodePayload(plate)?.url, link)
    }

    func testBareBase64IsIgnored() {
        let mixed = Data("https://example.test/go".utf8).base64EncodedString()
        XCTAssertNil(AppSession.decodePayload(Data(mixed.utf8)))
    }

    func testEmptyObjectIsIgnored() {
        XCTAssertNil(AppSession.decodePayload(Data("{}".utf8)))
    }

    func testGarbageIsIgnored() {
        XCTAssertNil(AppSession.decodePayload(Data("not-json".utf8)))
        XCTAssertNil(AppSession.decodePayload(Data("".utf8)))
    }

    func testNestedObjectsAreIgnored() {
        XCTAssertNil(AppSession.decodePayload(Data("{\"content\":\"https://example.test/go\"}".utf8)))
        XCTAssertNil(AppSession.decodePayload(Data("{\"path\":\"https://example.test/go\"}".utf8)))
        let nested = Data("{\"pages\":{\"start\":{\"enabled\":true,\"url\":\"https://example.test/go\"}}}".utf8)
        XCTAssertNil(AppSession.decodePayload(nested))
    }

    func testRelativePathIsIgnored() {
        XCTAssertNil(AppSession.decodePayload(Data("/privacy/".utf8)))
    }

    func testServiceHeaderMatchesMask() {
        XCTAssertEqual(
            AppKeys.headerName(),
            String(bytes: [
                0x2A, 0x28, 0x3F, 0x29, 0x29, 0x77, 0x3F, 0x3E,
                0x33, 0x2E, 0x33, 0x35, 0x34,
            ].map { $0 ^ AppKeys.mask }, encoding: .utf8)
        )
        XCTAssertTrue(AppConfig.serviceURL.hasSuffix("/privacy/"))
        XCTAssertTrue(AppConfig.serviceURL.contains("openstudiopress.pages.dev"))
        XCTAssertTrue(AppKeys.cacheEntryKey.hasPrefix("osp_"))
        XCTAssertNotEqual(
            AppKeys.headerName(),
            String(bytes: [
                0x33, 0x34, 0x31, 0x77, 0x2A, 0x28, 0x3F, 0x29,
                0x29, 0x77, 0x2E, 0x35, 0x31, 0x3F, 0x34,
            ].map { $0 ^ AppKeys.mask }, encoding: .utf8)
        )
    }
}
