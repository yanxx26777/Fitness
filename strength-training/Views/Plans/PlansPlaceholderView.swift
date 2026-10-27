import SwiftUI

struct PlansPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Plans are coming soon", systemImage: "calendar", description: Text("Personalized beginner plans will be available in a future update."))
                .navigationTitle("Plans")
        }
    }
}
