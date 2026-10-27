import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case today, plans, courses, data, profile
    var id: String { rawValue }
    var titleKey: String {
        switch self {
        case .today: "Today"
        case .plans: "Plans"
        case .courses: "Courses"
        case .data: "Data"
        case .profile: "Profile"
        }
    }
    var systemImage: String {
        switch self {
        case .today: "dumbbell"
        case .plans: "calendar"
        case .courses: "play.rectangle"
        case .data: "chart.line.uptrend.xyaxis"
        case .profile: "person.crop.circle"
        }
    }
}
