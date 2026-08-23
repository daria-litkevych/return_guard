import SwiftUI

struct PurchaseDetailView: View {
    @EnvironmentObject var model: AppModel
    let purchase: Purchase

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    model.closeDetail()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                    .font(.rgBody(15, weight: .medium))
                    .foregroundStyle(RG.accentDeep)
                }
                .padding(.top, 8)

                PlaceholderThumb(cornerRadius: 22, label: "PRODUCT SHOT")
                    .frame(height: 170)
                    .padding(.top, 8)

                Text(purchase.product).font(.rgHeading(25)).foregroundStyle(RG.ink).padding(.top, 18)
                Text("\(purchase.store) · \(purchase.priceLabel)")
                    .font(.rgBody(15)).foregroundStyle(RG.textSecondary).padding(.top, 3)

                if !purchase.returned {
                    returnCard.padding(.top, 20)
                }

                VStack(spacing: 0) {
                    detailRow("Purchased", purchase.purchaseDate.formatted(date: .long, time: .omitted))
                    RowDivider().padding(.horizontal, 14)
                    detailRow("Warranty until", purchase.warrantyEndDate.formatted(date: .long, time: .omitted))
                    RowDivider().padding(.horizontal, 14)
                    detailRow("Notes", "Add a note", muted: true)
                }
                .padding(4)
                .rgCard(padding: 0)
                .padding(.top, 14)

                VStack(spacing: 10) {
                    if !purchase.returned {
                        Button {
                            model.markReturned(purchase)
                        } label: {
                            Text("Mark as returned")
                                .font(.rgHeading(16))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(RG.ink))
                        }
                    }
                    Button {
                        model.deletePurchase(purchase)
                    } label: {
                        Text("Delete purchase")
                            .font(.rgBody(14, weight: .medium))
                            .foregroundStyle(RG.urgent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.top, 18)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 26)
        }
        .background(RG.background.ignoresSafeArea())
    }

    private var returnCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Return window").font(.rgBody(14, weight: .semibold)).foregroundStyle(chipColor)
                    Text(purchase.daysLeft >= 0 ? "\(purchase.daysLeft) days left" : "Window closed")
                        .font(.rgHeading(38, weight: .bold))
                        .foregroundStyle(chipColor)
                    Text("Return by \(purchase.returnDeadline.formatted(date: .long, time: .omitted))")
                        .font(.rgBody(14)).foregroundStyle(RG.textSecondary)
                }
                Spacer()
                Image(systemName: "clock").font(.system(size: 26)).foregroundStyle(chipColor)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(RG.ink.opacity(0.08))
                    Capsule().fill(chipColor).frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
            HStack(spacing: 9) {
                Text("Set reminder")
                    .font(.rgHeading(15)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(Capsule().fill(RG.accent))
                Text("View receipt")
                    .font(.rgHeading(15)).foregroundStyle(RG.ink)
                    .frame(maxWidth: .infinity).padding(.vertical, 13)
                    .background(Capsule().fill(RG.ink.opacity(0.05)))
            }
        }
        .padding(20)
        .background(RG.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 6)
    }

    private var progress: Double {
        let total = Double(purchase.returnWindowDays)
        let left = Double(max(purchase.daysLeft, 0))
        return total > 0 ? min(max((total - left) / total, 0), 1) : 1
    }
    private var chipColor: Color {
        switch purchase.urgency {
        case .urgent: return RG.urgent
        case .approaching: return RG.approach
        case .safe: return RG.accentDeep
        }
    }

    private func detailRow(_ label: String, _ value: String, muted: Bool = false) -> some View {
        HStack {
            Text(label).font(.rgBody(15)).foregroundStyle(RG.textSecondary)
            Spacer()
            Text(value)
                .font(.rgBody(15, weight: muted ? .regular : .medium))
                .foregroundStyle(muted ? RG.textTertiary : RG.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
    }
}
