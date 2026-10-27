import SwiftData

enum ModelContainerFactory {
    enum ConfigurationError: Error { case cloudKitNotConfigured }

    static func make(inMemory: Bool = false, cloudSyncEnabled: Bool = false) throws -> ModelContainer {
        guard !cloudSyncEnabled else { throw ConfigurationError.cloudKitNotConfigured }
        let schema = Schema([Exercise.self, WorkoutSession.self, ExerciseRecord.self, SetRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
