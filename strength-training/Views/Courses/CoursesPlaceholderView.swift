import SwiftUI

struct CoursesPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ContentUnavailableView("Courses are coming soon", systemImage: "play.rectangle", description: Text("Guided courses will be available in a future update."))
                NavigationLink("Exercise library") { ExerciseLibraryView() }
                    .padding()
            }
            .navigationTitle("Courses")
        }
    }
}
