import XCTest
import SwiftData
@testable import strength_training

@MainActor
final class SeedDataTests: XCTestCase {
    func test_seedIfNeeded_isIdempotent() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        SeedData.seedIfNeeded(context: container.mainContext)
        SeedData.seedIfNeeded(context: container.mainContext)
        let exercises = try container.mainContext.fetch(FetchDescriptor<Exercise>())
        XCTAssertEqual(exercises.count, 19)
        XCTAssertEqual(Set(exercises.compactMap(\.stableCatalogID)).count, 19)
    }
    func test_existingSeedReceivesStableCatalogIDWithoutChangingRecords() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        let exercise = Exercise(name: "Shoulder Press", dayType: .arms)
        let record = ExerciseRecord(trainingMode: .highWeightLowReps)
        container.mainContext.insert(exercise)
        container.mainContext.insert(record)
        record.exercise = exercise
        let id = exercise.id
        SeedData.seedIfNeeded(context: container.mainContext)
        XCTAssertEqual(exercise.id, id)
        XCTAssertEqual(record.exercise?.id, id)
        XCTAssertEqual(exercise.stableCatalogID, "shoulder-press")
        XCTAssertEqual(exercise.name, "Shoulder Press")
    }
    func test_backupRestoreImmediatelyPreservesChineseSeedDisplayAndHistory() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        SeedData.seedIfNeeded(context: container.mainContext)
        let exercise = try XCTUnwrap(try container.mainContext.fetch(FetchDescriptor<Exercise>()).first { $0.name == "Shoulder Press" })
        let id = exercise.id
        let session = WorkoutSession(dayType: .arms)
        session.isCompleted = true
        let record = ExerciseRecord(trainingMode: .highWeightLowReps)
        let set = SetRecord(setNumber: 1, weightLbs: 225, reps: 5)
        container.mainContext.insert(session)
        container.mainContext.insert(record)
        container.mainContext.insert(set)
        record.exercise = exercise
        record.session = session
        set.exerciseRecord = record
        try container.mainContext.save()
        let data = try BackupService.export(context: container.mainContext)
        try BackupService.restore(from: data, context: container.mainContext)
        let restored = try XCTUnwrap(try container.mainContext.fetch(FetchDescriptor<Exercise>()).first { $0.id == id })
        XCTAssertEqual(restored.recordsArray.count, 1)
        XCTAssertEqual(restored.recordsArray.first?.setsArray.first?.weightLbs, 225)
        XCTAssertEqual(restored.stableCatalogID, "shoulder-press")
        XCTAssertEqual(restored.displayName(locale: Locale(identifier: "zh-Hans")), "肩推")
    }
    func test_seedCatalogContainsUniqueStableIDs() {
        XCTAssertEqual(Set(ExerciseCatalogEntry.all.map(\.stableID)).count, 19)
    }
    func test_defaultExercise_hasSimplifiedChineseDisplayName() {
        let exercise = Exercise(name: "Shoulder Press", dayType: .arms)
        exercise.stableCatalogID = "shoulder-press"
        XCTAssertEqual(exercise.displayName(locale: Locale(identifier: "zh-Hans")), "肩推")
    }
    func test_missingChineseTranslation_fallsBackToEnglishValue() {
        XCTAssertEqual(AppLocalization.text("missing.example", fallback: "Example", locale: Locale(identifier: "zh-Hans")), "Example")
    }
}
