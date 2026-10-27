import SwiftUI

struct WorkoutTabView: View {
    @Bindable var viewModel: WorkoutViewModel
    var body: some View {
        Group {
            if viewModel.activeSession != nil {
                ExerciseListView(workoutVM: viewModel)
            } else {
                Color.uplift.bgElev.ignoresSafeArea()
            }
        }
        .sheet(item: $viewModel.sessionPendingEffortRating, onDismiss: {
            if let staged = viewModel.pendingSummaryAfterRating {
                viewModel.pendingSummaryAfterRating = nil
                viewModel.sessionPendingSummary = staged
            }
        }) { _ in
            EffortRatingView(onSave: { viewModel.saveEffortRating($0) },
                             onSkip: { viewModel.skipEffortRating() })
        }
        .fullScreenCover(item: $viewModel.sessionPendingSummary) { session in
            WorkoutSummaryView(session: session, workoutVM: viewModel)
        }
    }
}
