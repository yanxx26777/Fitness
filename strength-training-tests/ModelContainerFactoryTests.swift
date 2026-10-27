import XCTest
import SwiftData
@testable import strength_training

@MainActor
final class ModelContainerFactoryTests: XCTestCase {
    func test_makeInMemoryContainer_insertsAndFetchesExercise() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        container.mainContext.insert(Exercise(name: "Test", dayType: .arms))
        try container.mainContext.save()
        XCTAssertEqual(try container.mainContext.fetch(FetchDescriptor<Exercise>()).first?.name, "Test")
    }
    func test_makeLocalContainer_usesNoCloudKitDatabase() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        XCTAssertNil(container.configurations.first?.cloudKitContainerIdentifier)
        XCTAssertThrowsError(try ModelContainerFactory.make(inMemory: true, cloudSyncEnabled: true))
    }
    func test_makeContainer_registersAllFourBaselineModels() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        XCTAssertEqual(container.schema.entities.count, 4)
    }
}
