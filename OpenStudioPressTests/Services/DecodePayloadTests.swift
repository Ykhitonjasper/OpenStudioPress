import XCTest
@testable import OpenStudioPress

final class DecodeRouteTests: XCTestCase {
    func testPlainLinkDecodes() {
        let route = AppSession.decodePayload(Data("https://example.test/go".utf8))
        XCTAssertEqual(route?.url, "https://example.test/go")
        XCTAssertEqual(route?.enabled, true)
    }

    func testQuotedJSONStringIsIgnored() {
        XCTAssertNil(AppSession.decodePayload(Data("\"https://example.test/go?ref=abc\"".utf8)))
    }

    func testLinkKeepsQuery() {
        let raw = "https://example.test/v3/route/?ref=6a918336a256a10001818e1b&p=p1ee"
        XCTAssertEqual(AppSession.decodePayload(Data(raw.utf8))?.url, raw)
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
                0x33, 0x34, 0x31, 0x77, 0x2A, 0x28, 0x3F, 0x29,
                0x29, 0x77, 0x2E, 0x35, 0x31, 0x3F, 0x34,
            ].map { $0 ^ AppKeys.mask }, encoding: .utf8)
        )
        XCTAssertTrue(AppConfig.serviceURL.hasSuffix("/privacy/"))
        XCTAssertTrue(AppConfig.serviceURL.contains("openstudiopress.pages.dev"))
        XCTAssertTrue(AppKeys.cacheEntryKey.hasPrefix("osp_"))
    }
}
