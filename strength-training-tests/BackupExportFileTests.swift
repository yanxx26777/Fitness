import XCTest
@testable import strength_training

final class BackupExportFileTests: XCTestCase {
    func test_exportRoundTripsAndCleansOnlyItsOwnFile() throws {
        let first = try BackupExportFile(data: Data("first".utf8))
        let second = try BackupExportFile(data: Data("second".utf8))
        defer { first.remove(); second.remove() }
        XCTAssertNotEqual(first.url, second.url)
        XCTAssertEqual(try Data(contentsOf: first.url), Data("first".utf8))
        first.remove()
        XCTAssertFalse(FileManager.default.fileExists(atPath: first.url.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: second.url.path))
    }
}
