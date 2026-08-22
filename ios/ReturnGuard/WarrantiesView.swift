import SwiftUI

struct WarrantiesView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Warranties").font(.rgHeading(27)).foregroundStyle(RG.ink)
                Text("Return window closed, cover still active.")
                    .font(.rgBody(14))
                    .foregroundStyle(RG.textSecondary)
                    .padding(.top, 5)

                if model.warranties.isEmpty {
                    emptyState.padding(.top, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(model.warranties) { p in WarrantyCard(purchase: p) }
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 26)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            PlaceholderThumb(label: "—").frame(width: 68, height: 68)
            Text("No warranties yet").font(.rgHeading(20)).foregroundStyle(RG.ink).padding(.top, 12)
            Text("Once a return window expires, active warranties appear here — with their cover dates.")
                .font(.rgBody(15))
                .foregroundStyle(RG.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct WarrantyCard: View {
    let purchase: Purchase

    private var progress: Double {
        let total = purchase.warrantyEndDate.timeIntervalSince(purchase.purchaseDate)
        let elapsed = Date().timeIntervalSince(purchase.purchaseDate)
        guard total > 0 else { return 0 }
        return min(max(elapsed / total, 0), 1)
    }
    private var monthsLeft: Int {
        max(Calendar.current.dateComponents([.month], from: Date(), to: purchase.warrantyEndDate).month ?? 0, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 13) {
                PlaceholderThumb(label: "IMG").frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(purchase.product).font(.rgHeading(17)).foregroundStyle(RG.ink)
                    Text("\(purchase.store) · \(purchase.priceLabel)").font(.rgBody(13)).foregroundStyle(RG.textTertiary)
                }
                Spacer()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(RG.ink.opacity(0.08))
                    Capsule().fill(RG.accent).frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 5)
            HStack {
                Text("Covered until \(purchase.warrantyEndDate.formatted(.dateTime.month(.wide).year()))")
                    .font(.rgBody(13, weight: .medium))
                    .foregroundStyle(RG.textSecondary)
                Spacer()
                Text("\(monthsLeft) month\(monthsLeft == 1 ? "" : "s") left")
                    .font(.rgBody(13, weight: .medium))
                    .foregroundStyle(RG.textTertiary)
            }
        }
        .rgCard()
    }
}
