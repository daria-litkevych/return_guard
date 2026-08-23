import SwiftUI
import StoreKit

/// From the design's "Paywall" turn, adapted to the free-plan limit
/// (originally "5 active purchases", now `AppModel.freePurchaseLimit`).
/// Backed by real StoreKit 2 purchasing via `StoreManager` — see its
/// header comment for how that works without real App Store Connect
/// products or Xcode's own Run action, which this environment can't use.
struct PaywallView: View {
    @EnvironmentObject var model: AppModel
    @EnvironmentObject var store: StoreManager
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isPurchasing = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Not now") { model.dismissPaywall() }
                    .font(.rgBody(15, weight: .medium))
                    .foregroundStyle(RG.textTertiary)
            }
            .padding(.horizontal, 22)
            .padding(.top, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Track everything you buy")
                        .font(.rgHeading(27))
                        .foregroundStyle(RG.ink)
                        .padding(.top, 14)
                    Text("You're on the free plan: \(AppModel.freePurchaseLimit) active purchases, manual entry, basic reminders. Premium removes the limits and does the typing for you.")
                        .font(.rgBody(15))
                        .foregroundStyle(RG.textSecondary)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 16) {
                        featureRow(title: "Unlimited purchases", subtitle: "Track as much as you buy")
                        featureRow(title: "Receipt scanning", subtitle: "Photograph it, we read the details")
                        featureRow(title: "Warranty tracking", subtitle: "Cover dates kept after the return window")
                        featureRow(title: "Advanced reminders & receipt storage", subtitle: "Choose your own timing, keep every receipt")
                    }
                    .padding(18)
                    .rgCard(padding: 0)
                    .padding(.top, 20)

                    if store.isLoadingProducts {
                        HStack {
                            Spacer()
                            ProgressView().tint(RG.accent)
                            Spacer()
                        }
                        .padding(.top, 30)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(SubscriptionPlan.allCases) { plan in
                                planRow(plan)
                            }
                        }
                        .padding(.top, 22)
                    }

                    if let error = store.purchaseError {
                        Text(error)
                            .font(.rgBody(13))
                            .foregroundStyle(RG.urgent)
                            .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 16)
            }

            VStack(spacing: 12) {
                Button {
                    purchase()
                } label: {
                    ZStack {
                        Text(ctaLabel)
                            .opacity(isPurchasing ? 0 : 1)
                        if isPurchasing {
                            ProgressView().tint(.white)
                        }
                    }
                    .font(.rgHeading(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(RG.accent))
                    .shadow(color: RG.accent.opacity(0.32), radius: 12, x: 0, y: 6)
                }
                .disabled(isPurchasing || store.product(for: selectedPlan) == nil)

                HStack(spacing: 18) {
                    Button("Restore") { Task { await store.restore() } }
                    Text("Terms")
                    Text("Privacy")
                }
                .font(.rgBody(13))
                .foregroundStyle(RG.textTertiary)
            }
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 26)
        }
        .background(RG.background.ignoresSafeArea())
        .onChange(of: store.isPremium) { _, isPremium in
            if isPremium { model.dismissPaywall() }
        }
    }

    private var ctaLabel: String {
        let price = store.product(for: selectedPlan)?.displayPrice ?? selectedPlan.priceLabel
        return "Continue \(selectedPlan.rawValue) · \(price)"
    }

    private func purchase() {
        isPurchasing = true
        Task {
            await store.purchase(selectedPlan)
            isPurchasing = false
        }
    }

    private func featureRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(RG.safe)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.rgHeading(16)).foregroundStyle(RG.ink)
                Text(subtitle).font(.rgBody(13)).foregroundStyle(RG.textSecondary)
            }
            Spacer(minLength: 0)
        }
    }

    private func planRow(_ plan: SubscriptionPlan) -> some View {
        let selected = selectedPlan == plan
        let priceLabel = store.product(for: plan)?.displayPrice ?? plan.priceLabel
        return Button {
            selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title).font(.rgHeading(18)).foregroundStyle(RG.ink)
                    Text(plan.subtitle).font(.rgBody(14)).foregroundStyle(RG.textSecondary)
                }
                Spacer()
                Text(priceLabel).font(.rgHeading(22)).foregroundStyle(RG.ink)
            }
            .padding(18)
            .background(RG.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(selected ? RG.accent : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(selected ? 0.1 : 0.04), radius: selected ? 14 : 4, x: 0, y: selected ? 6 : 1)
            .overlay(alignment: .topLeading) {
                if plan == .yearly {
                    Text("Best value")
                        .font(.rgBody(11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(RG.accent))
                        .offset(x: 18, y: -11)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
