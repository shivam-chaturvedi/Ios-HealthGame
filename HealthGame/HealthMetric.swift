import SwiftUI

enum HealthCategory: String, CaseIterable {
    case activity = "Activity"
    case heart = "Heart"
    case sleep = "Sleep"
    case body = "Body"
    case workouts = "Workouts"

    var accent: LinearGradient {
        switch self {
        case .activity:
            return LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .heart:
            return LinearGradient(colors: [.red, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sleep:
            return LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .body:
            return LinearGradient(colors: [.mint, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .workouts:
            return LinearGradient(colors: [.teal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var tint: Color {
        switch self {
        case .activity:
            return .orange
        case .heart:
            return .red
        case .sleep:
            return .blue
        case .body:
            return .mint
        case .workouts:
            return .cyan
        }
    }
}

struct HealthMetric: Identifiable, Hashable {
    let id: String
    let title: String
    var value: String
    var detail: String
    let category: HealthCategory
    let systemImage: String
}
