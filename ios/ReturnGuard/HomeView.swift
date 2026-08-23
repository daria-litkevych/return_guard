import SwiftUI

struct HomeView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(greeting)
                    .font(.rgBody(15))
                    .foregroundStyle(RG.textSecondary)

                if model.returning.isEmpty {
                    caughtUpCard.padding(.top, 24)
                } else {
                    Text("\(model.returning.count) return\(model.returning.count == 1 ? "" : "s") need\(model.returning.count == 1 ? "s" : "") your attention")
                        .font(.rgHeading(27))
                        .foregroundStyle(RG.ink)
                        .padding(.top, 5)

                    if !model.soon.isEmpty {
                        sectionHeader("Returning soon").padding(.top, 22)
                        VStack(spacing: 12) {
                            ForEach(model.soon) { p in
                                ReturningSoonCard(purchase: p)
                                    .contentShape(Rectangle())
                                    .onTapGesture { model.openDetail(p) }
                            }
                        }
                        .padding(.top, 11)
                    }

                    if !model.safeForNow.isEmpty {
                        sectionHeader("Safe for now").padding(.top, 24)
                        VStack(spacing: 0) {
                            ForEach(Array(model.safeForNow.enumerated()), id: \.element.id) { idx, p in
                                if idx > 0 { RowDivider().padding(.horizontal, 12) }
                                CompactPurchaseRow(purchase: p)
                                    .contentShape(Rectangle())
                                    .onTapGesture { model.openDetail(p) }
                            }
                        }
                        .padding(6)
                        .rgCard(padding: 0)
                        .padding(.top, 11)
                    }

                    if let recent = model.recentlyAdded {
                        sectionHeader("Recently added").padding(.top, 24)
                        RecentlyAddedRow(purchase: recent).padding(.top, 11)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 26)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning, Daria"
        case 12..<18: return "Good afternoon, Daria"
        default: return "Good evening, Daria"
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.rgHeading(15)).foregroundStyle(RG.ink)
    }

    private var caughtUpCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(RG.accentTint).frame(width: 56, height: 56)
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(RG.accent)
            }
            VStack(spacing: 6) {
                Text("You're protected").font(.rgHeading(20)).foregroundStyle(RG.ink)
                Text("Nothing needs returning. Add a purchase and we'll watch the clock for you.")
                    .font(.rgBody(14))
                    .foregroundStyle(RG.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 38)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .rgCard(padding: 0)
    }
}

private struct ReturningSoonCard: View {
    let purchase: Purchase
    var body: some View {
        HStack(spacing: 14) {
            StoreIcon(store: purchase.store, size: 58, cornerRadius: 14)
            VStack(alignment: .leading, spacing: 8) {
                Text(purchase.product).font(.rgHeading(17)).foregroundStyle(RG.ink)
                Text("\(purchase.store) · \(purchase.priceLabel)").font(.rgBody(14)).foregroundStyle(RG.textSecondary)
                UrgencyChip(purchase: purchase)
            }
            Spacer(minLength: 0)
        }
        .rgCard()
    }
}

private struct CompactPurchaseRow: View {
    let purchase: Purchase
    var body: some View {
        HStack(spacing: 12) {
            StoreIcon(store: purchase.store, size: 38, cornerRadius: 11)
            VStack(alignment: .leading, spacing: 1) {
                Text(purchase.product).font(.rgBody(15, weight: .medium)).foregroundStyle(RG.ink)
                Text("\(purchase.store) · \(purchase.priceLabel)").font(.rgBody(13)).foregroundStyle(RG.textTertiary)
            }
            Spacer()
            Text("\(purchase.daysLeft) days").font(.rgBody(13, weight: .medium)).foregroundStyle(RG.textSecondary.opacity(0.9))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
    }
}

private struct RecentlyAddedRow: View {
    let purchase: Purchase
    var body: some View {
        HStack(spacing: 12) {
            StoreIcon(store: purchase.store, size: 38, cornerRadius: 11)
            VStack(alignment: .leading, spacing: 1) {
                Text(purchase.product).font(.rgBody(15, weight: .medium)).foregroundStyle(RG.ink)
                Text("Scanned just now").font(.rgBody(13)).foregroundStyle(RG.textTertiary)
            }
            Spacer()
            Image(systemName: "checkmark.circle").foregroundStyle(RG.safe)
        }
        .rgCard()
    }
}
