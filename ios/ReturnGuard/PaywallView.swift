import SwiftUI

/// From the design's "Paywall" turn, adapted to the free-plan limit
/// (originally "5 active purchases", now `AppModel.freePurchaseLimit`).
///
/// No real payment processing: there's no App Store Connect product
/// configuration or StoreKit integration behind this (and this
/// environment has no way to build/run via Xcode's own Run action, which
/// is what real StoreKit Testing requires — a headless `xcodebuild` +
/// `simctl launch` can't exercise it). Tapping a plan just flips a local
/// `isPremium` flag to demonstrate the gating behavior. Wiring up real
/// in-app purchases is separate follow-up work.
struct PaywallView: View {
    @EnvironmentObject var model: AppModel
    @State private var selectedPlan: SubscriptionPlan = .yearly

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

                    VStack(spacing: 10) {
                        ForEach(SubscriptionPlan.allCases) { plan in
                            planRow(plan)
                        }
                    }
                    .padding(.top, 22)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 16)
            }

            VStack(spacing: 12) {
                Button {
                    model.subscribe(to: selectedPlan)
                } label: {
                    Text(selectedPlan.ctaLabel)
                        .font(.rgHeading(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(RG.accent))
                        .shadow(color: RG.accent.opacity(0.32), radius: 12, x: 0, y: 6)
                }

                HStack(spacing: 18) {
                    Text("Restore")
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
        return Button {
            selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title).font(.rgHeading(18)).foregroundStyle(RG.ink)
                    Text(plan.subtitle).font(.rgBody(14)).foregroundStyle(RG.textSecondary)
                }
                Spacer()
                Text(plan.priceLabel).font(.rgHeading(22)).foregroundStyle(RG.ink)
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
