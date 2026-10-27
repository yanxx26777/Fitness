import XCTest
@testable import strength_training

final class AppTabTests: XCTestCase {
    func test_tabOrderIdentityAndSymbols() {
        XCTAssertEqual(AppTab.allCases, [.today, .plans, .courses, .data, .profile])
        XCTAssertEqual(Set(AppTab.allCases.map(\.rawValue)).count, 5)
        XCTAssertTrue(AppTab.allCases.allSatisfy { !$0.systemImage.isEmpty })
    }
    func test_chineseTabTitles() {
        XCTAssertEqual(AppTab.allCases.map { AppLocalization.text($0.titleKey, locale: Locale(identifier: "zh-Hans")) },
                       ["今日", "计划", "课程", "数据", "我的"])
    }
}
