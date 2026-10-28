import XCTest
@testable import strength_training

final class ProgressDeltaFormatterTests: XCTestCase {
    private let english = Locale(identifier: "en_US")

    func test_ordinaryPercentRoundsMagnitudeWithoutLosingPercentSign() {
        XCTAssertEqual(ProgressDeltaFormatter.percentMagnitude(23.4, locale: english), "23%")
        XCTAssertEqual(ProgressDeltaFormatter.percentMagnitude(-23.5, locale: english), "24%")
        XCTAssertEqual(ProgressDeltaFormatter.percentMagnitude(0, locale: english), "0%")
        XCTAssertEqual(ProgressDeltaFormatter.percentMagnitude(9_999, locale: english), "9,999%")
    }

    func test_hugeFinitePercentUsesBoundedMagnitude() {
        for percent in [9_999.5, 1e100, -1e100, Double.greatestFiniteMagnitude] {
            XCTAssertEqual(ProgressDeltaFormatter.percentMagnitude(percent, locale: english), "≥9,999%")
        }
    }

    func test_nonfinitePercentIsUnavailable() {
        for percent in [Double.nan, .infinity, -.infinity] {
            XCTAssertEqual(ProgressDeltaFormatter.percentMagnitude(percent, locale: english), "—")
        }
    }

    func test_percentUsesRequestedLocale() {
        XCTAssertEqual(
            ProgressDeltaFormatter.percentMagnitude(23, locale: Locale(identifier: "de_DE")),
            "23\u{00a0}%"
        )
    }
}
