import SwiftUI
import Combine
import Foundation

enum AppTab: Hashable { case home, purchases, warranties, settings }
enum ScanPhase { case idle, camera, confirm }

@MainActor
final class AppModel: ObservableObject {
    @Published var tab: AppTab = .home
    @Published var purchases: [Purchase] = Purchase.samples
    @Published var showAddSheet = false
    @Published var selectedPurchase: Purchase?
    @Published var scanPhase: ScanPhase = .idle

    private var scanTimer: Timer?

    var returning: [Purchase] { purchases.filter { $0.isReturnable }.sorted { $0.daysLeft < $1.daysLeft } }
    var soon: [Purchase] { returning.filter { $0.urgency != .safe } }
    var safeForNow: [Purchase] { returning.filter { $0.urgency == .safe } }
    var recentlyAdded: Purchase? { purchases.first { $0.recentlyAdded } }
    var warranties: [Purchase] { purchases.filter { $0.isUnderWarrantyOnly }.sorted { $0.warrantyEndDate < $1.warrantyEndDate } }

    func openAddSheet() { showAddSheet = true }

    func startScan() {
        showAddSheet = false
        scanPhase = .camera
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 1.9, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.finishScanCapture() }
        }
    }

    func shootNow() {
        scanTimer?.invalidate()
        finishScanCapture()
    }

    private func finishScanCapture() {
        withAnimation { scanPhase = .confirm }
    }

    func cancelScan() {
        scanTimer?.invalidate()
        withAnimation { scanPhase = .idle }
    }

    func acceptScan() {
        let newPurchase = Purchase(product: "Sony WH-1000XM6", store: "Amazon", price: 399.00,
                                    purchaseDate: Date(), returnWindowDays: 30, warrantyYears: 2,
                                    recentlyAdded: true)
        purchases.insert(newPurchase, at: 0)
        withAnimation {
            scanPhase = .idle
            tab = .home
        }
    }

    func openDetail(_ purchase: Purchase) {
        selectedPurchase = purchase
    }

    func closeDetail() {
        selectedPurchase = nil
    }

    func markReturned(_ purchase: Purchase) {
        if let idx = purchases.firstIndex(where: { $0.id == purchase.id }) {
            purchases[idx].returned = true
        }
        selectedPurchase = nil
    }

    func deletePurchase(_ purchase: Purchase) {
        purchases.removeAll { $0.id == purchase.id }
        selectedPurchase = nil
    }
}
