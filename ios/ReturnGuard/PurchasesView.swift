import SwiftUI

struct PurchasesView: View {
    @EnvironmentObject var model: AppModel
    @State private var query = ""
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable {
        case all = "All"
        case returningSoon = "Returning soon"
        case returned = "Returned"
        case expired = "Expired"
        case warranty = "Warranty"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Purchases").font(.rgHeading(27)).foregroundStyle(RG.ink)

                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass").foregroundStyle(RG.textTertiary)
                    TextField("Product, retailer, date", text: $query)
                        .font(.rgBody(15))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Capsule().fill(RG.surface))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
                .padding(.top, 14)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(Filter.allCases, id: \.self) { f in
                            filterChip(f)
                        }
                    }
                }
                .padding(.top, 14)

                VStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, p in
                        if idx > 0 { RowDivider().padding(.horizontal, 12) }
                        PurchaseListRow(purchase: p)
                            .contentShape(Rectangle())
                            .onTapGesture { model.openDetail(p) }
                    }
                }
                .padding(6)
                .rgCard(padding: 0)
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 26)
        }
    }

    private var filtered: [Purchase] {
        let base = model.purchases.filter {
            query.isEmpty
                || $0.product.localizedCaseInsensitiveContains(query)
                || $0.store.localizedCaseInsensitiveContains(query)
        }
        switch filter {
        case .all: return base
        case .returningSoon: return base.filter { $0.isReturnable }
        case .returned: return base.filter { $0.returned }
        case .expired: return base.filter { $0.isExpired }
        case .warranty: return base.filter { $0.isUnderWarrantyOnly }
        }
    }

    private func filterChip(_ f: Filter) -> some View {
        let selected = filter == f
        return Text(f.rawValue)
            .font(.rgBody(13, weight: .medium))
            .foregroundStyle(selected ? .white : RG.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(selected ? RG.ink : RG.surface))
            .onTapGesture { filter = f }
    }
}

private struct PurchaseListRow: View {
    let purchase: Purchase
    var body: some View {
        HStack(spacing: 12) {
            PlaceholderThumb(label: "IMG").frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 1) {
                Text(purchase.product).font(.rgBody(15, weight: .medium)).foregroundStyle(RG.ink)
                Text("\(purchase.store) · \(purchase.priceLabel)").font(.rgBody(13)).foregroundStyle(RG.textTertiary)
            }
            Spacer()
            UrgencyChip(purchase: purchase)
        }
        .padding(12)
        .opacity(purchase.isExpired ? 0.6 : 1)
    }
}
