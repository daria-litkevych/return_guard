import Foundation
import SwiftData

@Model
final class Purchase {
    /// Stable across the purchase's lifetime — used to key scheduled
    /// notification identifiers (SwiftData's own persistentModelID isn't
    /// guaranteed stable until first save).
    var id: UUID = UUID()
    var product: String
    var store: String
    var price: Double
    var purchaseDate: Date
    var returnWindowDays: Int
    var warrantyYears: Int
    var returned: Bool
    var recentlyAdded: Bool

    init(product: String, store: String, price: Double, purchaseDate: Date,
         returnWindowDays: Int, warrantyYears: Int, returned: Bool = false, recentlyAdded: Bool = false) {
        self.product = product
        self.store = store
        self.price = price
        self.purchaseDate = purchaseDate
        self.returnWindowDays = returnWindowDays
        self.warrantyYears = warrantyYears
        self.returned = returned
        self.recentlyAdded = recentlyAdded
    }

    enum Urgency { case safe, approaching, urgent }

    var returnDeadline: Date {
        Calendar.current.date(byAdding: .day, value: returnWindowDays, to: purchaseDate) ?? purchaseDate
    }
    var warrantyEndDate: Date {
        Calendar.current.date(byAdding: .year, value: warrantyYears, to: purchaseDate) ?? purchaseDate
    }
    var daysLeft: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: returnDeadline).day ?? 0
    }
    var isExpired: Bool { !returned && daysLeft < 0 }
    var isReturnable: Bool { !returned && !isExpired }
    var isUnderWarrantyOnly: Bool { !returned && isExpired && warrantyEndDate > Date() }

    var priceLabel: String { price.formatted(.currency(code: "EUR")) }

    var urgency: Urgency {
        if daysLeft <= 5 { return .urgent }
        if daysLeft <= 14 { return .approaching }
        return .safe
    }

    static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }

    static var samples: [Purchase] {
        [
            Purchase(product: "Sony WH-1000XM6", store: "Amazon", price: 399.00,
                     purchaseDate: daysAgo(25), returnWindowDays: 30, warrantyYears: 2),
            Purchase(product: "Zalando wool jacket", store: "Zalando", price: 89.00,
                     purchaseDate: daysAgo(19), returnWindowDays: 30, warrantyYears: 1),
            Purchase(product: "IKEA Malm desk", store: "IKEA", price: 149.00,
                     purchaseDate: daysAgo(6), returnWindowDays: 30, warrantyYears: 2),
            Purchase(product: "Uniqlo linen shirt", store: "Uniqlo", price: 39.90,
                     purchaseDate: daysAgo(2), returnWindowDays: 30, warrantyYears: 1),
            Purchase(product: "Philips Hue starter set", store: "MediaMarkt", price: 119.00,
                     purchaseDate: daysAgo(0), returnWindowDays: 30, warrantyYears: 2, recentlyAdded: true),
            Purchase(product: "Nike Pegasus 42", store: "Nike", price: 129.99,
                     purchaseDate: daysAgo(40), returnWindowDays: 30, warrantyYears: 1, returned: true),
            Purchase(product: "Anker power bank", store: "Amazon", price: 45.99,
                     purchaseDate: daysAgo(50), returnWindowDays: 30, warrantyYears: 1),
            Purchase(product: "Dyson V15 Detect", store: "MediaMarkt", price: 649.00,
                     purchaseDate: daysAgo(290), returnWindowDays: 30, warrantyYears: 2),
            Purchase(product: "Samsung 65\" TV", store: "Coolblue", price: 1199.00,
                     purchaseDate: daysAgo(766), returnWindowDays: 30, warrantyYears: 3),
        ]
    }
}
