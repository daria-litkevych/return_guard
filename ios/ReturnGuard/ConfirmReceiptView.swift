import SwiftUI

struct ConfirmReceiptView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button("Cancel") { model.cancelScan() }
                    .font(.rgBody(15, weight: .medium))
                    .foregroundStyle(RG.accentDeep)

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Receipt read")
                }
                .font(.rgBody(13, weight: .semibold))
                .foregroundStyle(RG.safe)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(RG.safeTint))
                .padding(.top, 14)

                Text("We found this").font(.rgHeading(27)).foregroundStyle(RG.ink).padding(.top, 12)
                Text("Check it before we start the countdown. Tap any field to fix it.")
                    .font(.rgBody(15))
                    .foregroundStyle(RG.textSecondary)
                    .padding(.top, 4)

                VStack(spacing: 0) {
                    field("Product", "Sony WH-1000XM6")
                    RowDivider().padding(.horizontal, 14)
                    field("Store", "Amazon")
                    RowDivider().padding(.horizontal, 14)
                    field("Price", "€399.00")
                    RowDivider().padding(.horizontal, 14)
                    field("Purchase date", Date().formatted(date: .long, time: .omitted))
                }
                .padding(4)
                .rgCard(padding: 0)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text("Estimated")
                    }
                    .font(.rgBody(13, weight: .semibold))
                    .foregroundStyle(RG.accentDeep)

                    Text("Return deadline may be \(estimatedDeadline.formatted(date: .long, time: .omitted))")
                        .font(.rgHeading(17))
                        .foregroundStyle(RG.ink)
                    Text("Based on Amazon's standard 30-day return policy — the receipt doesn't state one. Change it if you know better.")
                        .font(.rgBody(14))
                        .foregroundStyle(RG.textSecondary)
                }
                .padding(16)
                .background(RG.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(RG.accent.opacity(0.5), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Warranty").font(.rgBody(13)).foregroundStyle(RG.textTertiary)
                    Text("2 years · until \(warrantyEnd.formatted(date: .long, time: .omitted))")
                        .font(.rgBody(17, weight: .medium))
                        .foregroundStyle(RG.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.vertical, 13)
                .rgCard(padding: 0)
                .padding(.top, 12)

                VStack(spacing: 10) {
                    Button {
                        model.acceptScan()
                    } label: {
                        Text("Looks correct")
                            .font(.rgHeading(16))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Capsule().fill(RG.accent))
                    }
                    Text("Edit fields")
                        .font(.rgHeading(16))
                        .foregroundStyle(RG.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(RG.ink.opacity(0.05)))
                }
                .padding(.top, 18)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 26)
        }
        .background(RG.background.ignoresSafeArea())
    }

    private var estimatedDeadline: Date {
        Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    }
    private var warrantyEnd: Date {
        Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
    }

    private func field(_ label: String, _ value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.rgBody(13)).foregroundStyle(RG.textTertiary)
                Text(value).font(.rgBody(17, weight: .medium)).foregroundStyle(RG.ink)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
