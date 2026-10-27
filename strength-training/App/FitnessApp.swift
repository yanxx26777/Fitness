import SwiftUI
import SwiftData

@main
struct FitnessApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainerFactory.make()
        } catch {
            fatalError("Failed to create local store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(container)
    }
}
