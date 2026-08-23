import Foundation

/// Best-effort fields pulled from OCR'd receipt text. Nothing here is
/// guaranteed — the confirm screen always shows these as editable fields.
struct ParsedReceipt {
    var store: String?
    var price: Double?
    var date: Date?
}

enum ReceiptParser {
    /// `lines` are individual recognized text lines from Vision, roughly in
    /// on-page reading order (top to bottom).
    static func parse(lines: [String]) -> ParsedReceipt {
        var result = ParsedReceipt()

        // Store name heuristic: the first line that looks like a name rather
        // than a barcode/number/date line. Receipts print the store name
        // (or its logo as text) at the very top.
        result.store = lines.first { line in
            line.filter(\.isLetter).count >= 3
        }?.trimmingCharacters(in: .whitespaces)

        // Price heuristic: collect every currency-shaped number on the
        // receipt and take the largest — usually the total, since line
        // items are smaller than the sum of themselves plus tax.
        if let priceRegex = try? NSRegularExpression(pattern: #"[€$£]?\s?(\d{1,4}[.,]\d{2})\b"#) {
            var prices: [Double] = []
            for line in lines {
                let ns = line as NSString
                let matches = priceRegex.matches(in: line, range: NSRange(location: 0, length: ns.length))
                for match in matches where match.numberOfRanges > 1 {
                    let numStr = ns.substring(with: match.range(at: 1)).replacingOccurrences(of: ",", with: ".")
                    if let value = Double(numStr) { prices.append(value) }
                }
            }
            result.price = prices.max()
        }

        // Date heuristic: first line Foundation's date detector recognizes.
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) {
            for line in lines {
                let ns = line as NSString
                if let match = detector.firstMatch(in: line, range: NSRange(location: 0, length: ns.length)),
                   let date = match.date {
                    result.date = date
                    break
                }
            }
        }

        return result
    }
}

/// Editable draft backing the confirm/manual-entry form.
struct ReceiptDraft {
    var product: String = ""
    var store: String = ""
    var priceText: String = ""
    var purchaseDate: Date = Date()
    var returnWindowDays: Int = 30
    var warrantyYears: Int = 1

    init() {}

    init(from parsed: ParsedReceipt) {
        store = parsed.store ?? ""
        if let price = parsed.price {
            priceText = String(format: "%.2f", price)
        }
        if let date = parsed.date {
            purchaseDate = date
        }
    }

    var price: Double {
        Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var isValid: Bool {
        !product.trimmingCharacters(in: .whitespaces).isEmpty && price > 0
    }

    func makePurchase() -> Purchase {
        Purchase(
            product: product.trimmingCharacters(in: .whitespaces),
            store: store.trimmingCharacters(in: .whitespaces).isEmpty ? "Unknown store" : store,
            price: price,
            purchaseDate: purchaseDate,
            returnWindowDays: returnWindowDays,
            warrantyYears: warrantyYears,
            recentlyAdded: true
        )
    }
}

/// Codable mirror of `Purchase` for the "Export my data" JSON file — SwiftData
/// models aren't directly Codable-friendly to hand to a share sheet.
struct PurchaseExport: Codable {
    var product: String
    var store: String
    var price: Double
    var purchaseDate: Date
    var returnWindowDays: Int
    var warrantyYears: Int
    var returned: Bool

    init(_ purchase: Purchase) {
        product = purchase.product
        store = purchase.store
        price = purchase.price
        purchaseDate = purchase.purchaseDate
        returnWindowDays = purchase.returnWindowDays
        warrantyYears = purchase.warrantyYears
        returned = purchase.returned
    }
}
