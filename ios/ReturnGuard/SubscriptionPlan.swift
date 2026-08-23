import Foundation

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case yearly, monthly, lifetime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yearly: return "Yearly"
        case .monthly: return "Monthly"
        case .lifetime: return "Lifetime"
        }
    }

    var subtitle: String {
        switch self {
        case .yearly: return "€2.50 / month · save 50%"
        case .monthly: return "Cancel anytime"
        case .lifetime: return "One payment, forever"
        }
    }

    var priceLabel: String {
        switch self {
        case .yearly: return "€29.99"
        case .monthly: return "€4.99"
        case .lifetime: return "€49.99"
        }
    }

    var ctaLabel: String {
        "Continue \(rawValue) · \(priceLabel)"
    }
}
