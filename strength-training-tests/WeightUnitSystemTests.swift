import XCTest
@testable import strength_training

final class WeightUnitSystemTests: XCTestCase {
    func test_conversionAndRoundTrip() {
        XCTAssertEqual(WeightUnitSystem.metric.fromStoredPounds(100), 45.3592, accuracy: 0.0001)
        XCTAssertEqual(WeightUnitSystem.metric.toStoredPounds(50), 110.231, accuracy: 0.001)
        for unit in WeightUnitSystem.allCases {
            XCTAssertEqual(unit.toStoredPounds(unit.fromStoredPounds(225)), 225, accuracy: 0.001)
        }
    }
    func test_stepsAndFormatting() {
        XCTAssertEqual(WeightUnitSystem.metric.inputStep, 2.5)
        XCTAssertEqual(WeightUnitSystem.imperial.inputStep, 5)
        XCTAssertEqual(WeightUnitSystem.metric.formatStoredPounds(110.23113109), "50")
        XCTAssertEqual(WeightUnitSystem.imperial.formatStoredPounds(142.5), "142.5")
    }
    func test_invalidRawValue_fallsBackToMetric() {
        XCTAssertEqual(WeightUnitSystem.resolve(rawValue: "broken"), .metric)
        XCTAssertEqual(WeightUnitSystem.resolve(rawValue: nil), .metric)
    }
    func test_displayWeight_sanitizesInvalidValues() {
        for unit in WeightUnitSystem.allCases {
            for value in [-1, Double.nan, .infinity, 1e100] {
                let result = unit.formatStoredPounds(value)
                XCTAssertFalse(result.lowercased().contains("nan"))
                XCTAssertFalse(result.lowercased().contains("inf"))
                XCTAssertFalse(result.contains("-"))
            }
        }
    }
    func test_inputDisplaySanitizesHistoricalWeightsWithoutChangingStorage() {
        for unit in WeightUnitSystem.allCases {
            for pounds in [-1, Double.nan, .infinity, 1e100] {
                let display = unit.displayWeight(fromStoredPounds: pounds)
                XCTAssertTrue(display.isFinite)
                XCTAssertGreaterThanOrEqual(display, 0)
                XCTAssertLessThanOrEqual(display, unit.fromStoredPounds(10_000))
            }
        }
    }
    func test_newlyLoggedWeightIsFiniteNonnegativeAndWithinInputMaximum() {
        let cases: [(input: Double, expected: Double)] = [
            (225.5, 225.5), (0, 0), (-1, 0), (.nan, 0),
            (-.infinity, 0), (.infinity, 10_000),
            (10_000, 10_000), (10_001, 10_000), (1e100, 10_000)
        ]
        for (input, expected) in cases {
            let loggedWeight = WeightUnitSystem.normalizedInputStoredPounds(input)
            XCTAssertTrue(loggedWeight.isFinite)
            XCTAssertEqual(loggedWeight, expected)
        }
    }
    func test_signedWeightDeltaPreservesDecrease() {
        XCTAssertEqual(WeightUnitSystem.imperial.formatSignedStoredPounds(-5), "−5")
        XCTAssertEqual(WeightUnitSystem.metric.formatSignedStoredPounds(-5), "−2.3")
        XCTAssertEqual(WeightUnitSystem.imperial.formatSignedStoredPounds(5), "+5")
    }
    func test_volumePreservesLargeValidTotals() {
        XCTAssertEqual(TodayStats.formatVolume(200_000, unit: .imperial), "200,000")
        XCTAssertEqual(TodayStats.formatVolume(110.23113109, unit: .metric), "50")
    }
}
