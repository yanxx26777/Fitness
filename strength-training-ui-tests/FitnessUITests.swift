import XCTest

@MainActor
final class FitnessUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testChineseShellLibraryAndBackupPresentation() {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()
        if app.buttons["收起训练"].waitForExistence(timeout: 3) {
            app.buttons["收起训练"].tap()
        }
        XCTAssertTrue(app.buttons["今日"].waitForExistence(timeout: 10))
        for title in ["今日", "计划", "课程", "数据", "我的"] {
            XCTAssertTrue(app.buttons[title].exists)
        }
        app.buttons["计划"].tap()
        XCTAssertTrue(app.staticTexts["训练计划即将上线"].waitForExistence(timeout: 5))
        app.buttons["课程"].tap()
        app.buttons["动作库"].tap()
        XCTAssertTrue(app.staticTexts["肩推"].waitForExistence(timeout: 5))
        app.buttons["添加动作"].tap()
        XCTAssertTrue(app.buttons["上肢"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["上肢"].isSelected)
        app.buttons["下肢"].tap()
        XCTAssertTrue(app.buttons["下肢"].isSelected)
        app.buttons["取消"].tap()
        app.buttons["我的"].tap()
        XCTAssertTrue(app.staticTexts["数据保存在此设备"].waitForExistence(timeout: 5))
        app.buttons["导出备份"].tap()
        XCTAssertTrue(app.otherElements["ActivityListView"].waitForExistence(timeout: 5) || app.buttons["Copy"].exists || app.buttons["拷贝"].exists,
                      app.debugDescription)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Chinese backup share sheet"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    func testWorkoutRecordsMetricSetAndReturnsToShell() {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN", "-weightUnitSystem", "metric"]
        app.launch()
        if app.buttons["收起训练"].waitForExistence(timeout: 3) {
            app.buttons["收起训练"].tap()
        }
        let start = app.buttons.matching(NSPredicate(format: "label IN %@", ["开始训练", "继续训练"])).firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 10), app.debugDescription)
        start.tap()
        let shoulder = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "肩推")).firstMatch
        XCTAssertTrue(shoulder.waitForExistence(timeout: 5), app.debugDescription)
        shoulder.tap()
        XCTAssertTrue(app.buttons["记录此组"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["计划"].isHittable)
        app.buttons["增加 重量"].tap()
        app.buttons["记录此组"].tap()
        let celebration = app.buttons["关闭纪录庆祝"]
        if celebration.waitForExistence(timeout: 2) {
            let continueButton = app.buttons.matching(identifier: "继续训练").allElementsBoundByIndex.first { $0.isHittable }
            XCTAssertNotNil(continueButton, app.debugDescription)
            continueButton?.tap()
            expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: celebration)
            waitForExpectations(timeout: 5)
        }
        app.buttons["返回动作列表"].tap()
        app.buttons["结束训练"].tap()
        let confirm = app.buttons.matching(identifier: "结束训练").allElementsBoundByIndex.first { $0.isHittable }
        XCTAssertNotNil(confirm, app.debugDescription)
        confirm?.tap()
        XCTAssertTrue(app.staticTexts["训练完成"].waitForExistence(timeout: 10), app.debugDescription)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Chinese workout summary"
        attachment.lifetime = .keepAlways
        add(attachment)
        app.buttons["完成"].tap()
        XCTAssertTrue(app.buttons["计划"].waitForExistence(timeout: 5))
    }

}
