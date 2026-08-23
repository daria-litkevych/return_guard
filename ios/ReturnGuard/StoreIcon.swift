import SwiftUI

/// Maps a handful of known retailer names to their domain, so we only ever
/// request a logo for a store we can confidently identify — never by
/// guessing a domain from arbitrary user text (which could leak a typo'd
/// or unrelated site's favicon to a third party).
enum StoreDirectory {
    private static let domains: [String: String] = [
        "amazon": "amazon.com",
        "zalando": "zalando.com",
        "ikea": "ikea.com",
        "uniqlo": "uniqlo.com",
        "mediamarkt": "mediamarkt.de",
        "media markt": "mediamarkt.de",
        "nike": "nike.com",
        "coolblue": "coolblue.nl",
        "dyson": "dyson.com",
        "samsung": "samsung.com",
        "philips hue": "philips-hue.com",
        "hue": "philips-hue.com",
        "philips": "philips.com",
        "apple": "apple.com",
        "asos": "asos.com",
        "target": "target.com",
        "walmart": "walmart.com",
        "best buy": "bestbuy.com",
        "bestbuy": "bestbuy.com",
        "etsy": "etsy.com",
        "ebay": "ebay.com",
        "h&m": "hm.com",
        "hm": "hm.com",
        "wayfair": "wayfair.com",
        "sephora": "sephora.com",
        "adidas": "adidas.com",
        "bol.com": "bol.com",
        "bol": "bol.com",
        "otto": "otto.de",
        "decathlon": "decathlon.com",
    ]

    /// Google's public favicon service — used the same way many
    /// finance/expense-tracking apps show a merchant's icon for
    /// identification, not endorsement. Live-fetched rather than bundled,
    /// so no third-party logo ever ships inside the app binary. (Clearbit's
    /// logo.clearbit.com, the other well-known free option, no longer
    /// resolves at all — this one was verified working.) Quality varies
    /// with whatever favicon each site actually has (often only 16–64px),
    /// so this trades crispness for something that reliably returns a
    /// real, decodable image — StoreIcon falls back to the monogram on
    /// any failure regardless.
    static func logoURL(for store: String) -> URL? {
        let key = store.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !key.isEmpty, let domain = domains[key] else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?sz=128&domain=\(domain)")
    }
}

/// A store's logo where we recognize the name, live-fetched and cached by
/// the system URL cache; a deterministic colored monogram everywhere else
/// (unrecognized store, offline, fetch failure) so the UI never shows a
/// broken-image glyph.
struct StoreIcon: View {
    let store: String
    var size: CGFloat = 42
    var cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if let url = StoreDirectory.logoURL(for: store) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFit().padding(size * 0.16)
                    } else {
                        monogram
                    }
                }
            } else {
                monogram
            }
        }
        .frame(width: size, height: size)
        .background(RG.surface)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(RG.divider)
        )
    }

    private var monogram: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(monogramColor.opacity(0.14))
            Text(initial)
                .font(.rgHeading(size * 0.42))
                .foregroundStyle(monogramColor)
        }
    }

    private var initial: String {
        let trimmed = store.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.first.map { String($0).uppercased() } ?? "?"
    }

    private var monogramColor: Color {
        let palette: [Color] = [RG.accent, RG.safe, RG.approach, RG.urgent, RG.accentDeep]
        let key = store.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !key.isEmpty else { return RG.textTertiary }
        // A fixed hash (djb2), not String.hashValue — that's seeded per
        // process, so the same store would pick a different color on
        // every launch.
        var hash: UInt64 = 5381
        for byte in key.utf8 { hash = 33 &* hash &+ UInt64(byte) }
        return palette[Int(hash % UInt64(palette.count))]
    }
}
