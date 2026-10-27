import SwiftUI

struct AppShellView: View {
    @Bindable var workoutViewModel: WorkoutViewModel
    var healthKitService: HealthKitWorkoutService
    var cloudKitSyncService: CloudKitSyncService
    @State private var selection: AppTab = .today
    @AppStorage("weightUnitSystem") private var savedUnit = "metric"

    var body: some View {
        TabView(selection: $selection) {
            TodayView(workoutVM: workoutViewModel)
                .tabItem { tabLabel(.today) }.tag(AppTab.today)
            PlansPlaceholderView()
                .tabItem { tabLabel(.plans) }.tag(AppTab.plans)
            CoursesPlaceholderView()
                .tabItem { tabLabel(.courses) }.tag(AppTab.courses)
            NavigationStack {
                List {
                    NavigationLink("Training history") { HistoryListView() }
                    NavigationLink("Trends and records") { ProgressDashboardView() }
                }
                .navigationTitle("Data")
            }
            .tabItem { tabLabel(.data) }.tag(AppTab.data)
            SettingsView(healthKitService: healthKitService, cloudKitSyncService: cloudKitSyncService)
                .tabItem { tabLabel(.profile) }.tag(AppTab.profile)
        }
        // Reading the preference invalidates all presentation boundaries when it changes.
        .id(savedUnit)
        .fullScreenCover(isPresented: Binding(
            get: {
                workoutViewModel.activeSession != nil ||
                workoutViewModel.sessionPendingEffortRating != nil ||
                workoutViewModel.pendingSummaryAfterRating != nil ||
                workoutViewModel.sessionPendingSummary != nil
            },
            set: { _ in }
        )) {
            WorkoutTabView(viewModel: workoutViewModel)
                .interactiveDismissDisabled()
        }
    }

    private func tabLabel(_ tab: AppTab) -> some View {
        Label(AppLocalization.text(tab.titleKey), systemImage: tab.systemImage)
    }
}
