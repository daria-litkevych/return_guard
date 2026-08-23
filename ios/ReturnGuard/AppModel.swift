import SwiftUI
import Combine
import Foundation
import SwiftData
import UIKit

enum AppTab: Hashable { case home, purchases, warranties, settings }

/// .scanning presents the real camera (VisionKit), .processing runs OCR on
/// the captured page, .review shows the editable confirm/manual-entry form.
enum ScanPhase: Equatable { case idle, scanning, processing, review }

@MainActor
final class AppModel: ObservableObject {
    @Published var tab: AppTab = .home
    @Published private(set) var purchases: [Purchase] = []
    @Published var showAddSheet = false
    @Published var selectedPurchase: Purchase?
    @Published var scanPhase: ScanPhase = .idle
    @Published var draft = ReceiptDraft()
    @Published var scanErrorMessage: String?

    var modelContext: ModelContext?

    /// Called from RootView whenever the `@Query`-backed purchase list changes.
    func sync(_ purchases: [Purchase]) {
        self.purchases = purchases
    }

    /// Gates on a persisted flag rather than `purchases.isEmpty` — RootView's
    /// `onAppear` can fire more than once per install (e.g. across relaunches
    /// during development), and the in-memory `purchases` array can still
    /// read empty on a very first call if the `@Query` hasn't delivered its
    /// initial fetch yet. Either gap would silently reseed the sample seven
    /// on top of what's already there. A UserDefaults flag makes "seed
    /// exactly once per install" true regardless of that timing.
    private static let hasSeededKey = "hasSeededSampleData"

    func seedIfNeeded() {
        guard let context = modelContext, !UserDefaults.standard.bool(forKey: Self.hasSeededKey) else { return }
        UserDefaults.standard.set(true, forKey: Self.hasSeededKey)
        for purchase in Purchase.samples { context.insert(purchase) }
        try? context.save()
    }

    var returning: [Purchase] { purchases.filter { $0.isReturnable }.sorted { $0.daysLeft < $1.daysLeft } }
    var soon: [Purchase] { returning.filter { $0.urgency != .safe } }
    var safeForNow: [Purchase] { returning.filter { $0.urgency == .safe } }
    var recentlyAdded: Purchase? { purchases.first { $0.recentlyAdded } }
    var warranties: [Purchase] { purchases.filter { $0.isUnderWarrantyOnly }.sorted { $0.warrantyEndDate < $1.warrantyEndDate } }

    // MARK: Add purchase sheet

    func openAddSheet() {
        showAddSheet = true
    }

    func startScan() {
        showAddSheet = false
        scanErrorMessage = nil
        scanPhase = .scanning
    }

    func startManualEntry() {
        showAddSheet = false
        draft = ReceiptDraft()
        scanPhase = .review
    }

    // MARK: Scan -> OCR -> review

    func handleScannedImage(_ image: UIImage) {
        scanPhase = .processing
        Task {
            do {
                let lines = try await ReceiptOCR.recognizeLines(in: image)
                let parsed = ReceiptParser.parse(lines: lines)
                draft = ReceiptDraft(from: parsed)
                scanPhase = .review
            } catch {
                scanErrorMessage = "We couldn't read that receipt. Try again, or enter it manually."
                scanPhase = .idle
            }
        }
    }

    func cancelScan() {
        scanPhase = .idle
    }

    func saveDraft() {
        guard let context = modelContext, draft.isValid else { return }
        context.insert(draft.makePurchase())
        try? context.save()
        scanPhase = .idle
        tab = .home
    }

    // MARK: Purchase detail

    func openDetail(_ purchase: Purchase) {
        selectedPurchase = purchase
    }

    func closeDetail() {
        selectedPurchase = nil
    }

    func markReturned(_ purchase: Purchase) {
        purchase.returned = true
        try? modelContext?.save()
        selectedPurchase = nil
    }

    func deletePurchase(_ purchase: Purchase) {
        modelContext?.delete(purchase)
        try? modelContext?.save()
        selectedPurchase = nil
    }

    // MARK: Settings

    func deleteAllData() {
        guard let context = modelContext else { return }
        for purchase in purchases { context.delete(purchase) }
        try? context.save()
    }

    /// Writes the current purchases to a temp JSON file and returns its URL,
    /// for a `ShareLink` in Settings. Best-effort: falls back to an empty
    /// array rather than throwing, since this backs a UI affordance.
    func exportURL() -> URL {
        let items = purchases.map(PurchaseExport.init)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = (try? encoder.encode(items)) ?? Data("[]".utf8)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("returnguard-export.json")
        try? data.write(to: url, options: .atomic)
        return url
    }
}
