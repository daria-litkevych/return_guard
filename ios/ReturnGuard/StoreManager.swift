import Foundation
import StoreKit

/// Real StoreKit 2 purchasing, backed by `ReturnGuard.storekit` — a local
/// StoreKit Testing configuration wired into the Xcode scheme (see
/// `ReturnGuard.xcodeproj/xcshareddata/xcschemes/ReturnGuard.xcscheme`),
/// so `Product.products(for:)` and purchases resolve against local test
/// data instead of the real App Store when run from Xcode.
///
/// This deliberately does NOT use `SKTestSession` to load that
/// configuration programmatically from app code — that path exists and
/// looked promising for testing outside Xcode (this environment can only
/// launch the app via `simctl launch`, never Xcode's own Run action), but
/// it hard-crashes (`SIGABRT` inside `-[SKTestSession bundleID]`) unless
/// launched from a real XCTest hosting context, confirmed by an actual
/// crash log here. `SKTestSession` is a testing-target tool, not a
/// general app-code one, whatever some examples suggest. The scheme-based
/// route below is what Apple actually documents for exercising StoreKit
/// Testing from a plain Run, and it's what real Xcode use gets for free.
///
/// Practical effect: in Xcode, Run and this works end-to-end against the
/// local test products. In this environment (no Xcode Run action
/// available), `Product.products(for:)` has nothing to resolve against —
/// no StoreKit Configuration is active and no real App Store Connect
/// products exist under these IDs — so it correctly returns empty and
/// the paywall shows "No plans available right now." rather than
/// fabricating prices or silently pretending to work.
@MainActor
final class StoreManager: ObservableObject {
    enum ProductID: String, CaseIterable {
        case yearly = "com.darialitkevych.ReturnGuard.premium.yearly"
        case monthly = "com.darialitkevych.ReturnGuard.premium.monthly"
        case lifetime = "com.darialitkevych.ReturnGuard.premium.lifetime"

        var plan: SubscriptionPlan {
            switch self {
            case .yearly: return .yearly
            case .monthly: return .monthly
            case .lifetime: return .lifetime
            }
        }
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium = false
    @Published private(set) var activePlan: SubscriptionPlan?
    @Published var isLoadingProducts = false
    @Published var purchaseError: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
            }
        }

        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let fetched = try await Product.products(for: ProductID.allCases.map(\.rawValue))
            products = fetched.sorted { orderIndex(of: $0.id) < orderIndex(of: $1.id) }
            if fetched.isEmpty {
                purchaseError = "No plans available right now."
            } else {
                purchaseError = nil
            }
        } catch {
            print("ReturnGuard: failed to load products — \(error)")
            purchaseError = "Couldn't load plans. Check your connection and try again."
        }
    }

    private func orderIndex(of id: String) -> Int {
        ProductID.allCases.firstIndex { $0.rawValue == id } ?? .max
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        products.first { $0.id == productID(for: plan) }
    }

    private func productID(for plan: SubscriptionPlan) -> String {
        switch plan {
        case .yearly: return ProductID.yearly.rawValue
        case .monthly: return ProductID.monthly.rawValue
        case .lifetime: return ProductID.lifetime.rawValue
        }
    }

    func purchase(_ plan: SubscriptionPlan) async {
        purchaseError = nil
        guard let product = product(for: plan) else {
            purchaseError = "That plan isn't available right now."
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("ReturnGuard: purchase failed — \(error)")
            purchaseError = "Purchase failed. Try again."
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard let transaction = try? checkVerified(result) else { return }
        await transaction.finish()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var owned: ProductID?
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if let id = ProductID(rawValue: transaction.productID) {
                owned = id
                break
            }
        }
        isPremium = owned != nil
        activePlan = owned?.plan
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error { case failedVerification }
}
