//
//  ContentView.swift
//  strength-training
//
//  Created by Daniel Kuhlwein on 2026-02-21.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var workoutViewModel: WorkoutViewModel?
    @State private var healthKitService = HealthKitWorkoutService()
    @State private var cloudKitSyncService = CloudKitSyncService()
    @State private var selectedTab = "workout"

    var body: some View {
        Group {
            if let vm = workoutViewModel {
                AppShellView(workoutViewModel: vm, healthKitService: healthKitService,
                             cloudKitSyncService: cloudKitSyncService)
            } else {
                // Mirrors the UILaunchScreen (LaunchBackground + LaunchGlyph) so the
                // handoff from the system launch screen is seamless.
                ZStack {
                    Color.uplift.bgElev.ignoresSafeArea()
                    Image("LaunchGlyph")
                }
            }
        }
        .tint(Color.uplift.accent)
        .preferredColorScheme(.dark)
        .onAppear {
            SeedData.migrateExerciseNames(context: modelContext)
            SeedData.seedIfNeeded(context: modelContext)
            if workoutViewModel == nil {
                workoutViewModel = WorkoutViewModel(modelContext: modelContext, healthKitService: healthKitService)
            }
        }

    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
