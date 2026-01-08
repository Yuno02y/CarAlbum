import SwiftUI

enum BackgroundStyle: String, CaseIterable, Identifiable {
    case classic = "classic"
    case garage = "garage"
    case night = "night"
    case gradient = "gradient"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic:
            return "クラシック"
        case .garage:
            return "ガレージ"
        case .night:
            return "ナイト"
        case .gradient:
            return "グラデ"
        }
    }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .classic:
            Color(.systemBackground)
        case .garage:
            LinearGradient(
                colors: [Color(white: 0.18), Color(white: 0.28)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .night:
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.45)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .gradient:
            LinearGradient(
                colors: [Color.orange.opacity(0.4), Color.pink.opacity(0.35), Color.purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
