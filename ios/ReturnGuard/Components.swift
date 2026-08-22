import SwiftUI

struct PlaceholderThumb: View {
    var cornerRadius: CGFloat = 12
    var label: String = "IMG"

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(RG.accent.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                    .foregroundStyle(RG.accent.opacity(0.35))
            )
            .overlay(
                Text(label)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(RG.ink.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(4)
            )
    }
}

struct RowDivider: View {
    var body: some View {
        Rectangle().fill(RG.divider).frame(height: 1)
    }
}

extension View {
    func chipBackground(_ color: Color) -> some View {
        self.padding(.horizontal, 10).padding(.vertical, 4)
            .background(Capsule().fill(color))
    }
}

struct UrgencyChip: View {
    let purchase: Purchase

    var body: some View {
        Group {
            if purchase.returned {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Returned")
                }
                .foregroundStyle(RG.safe)
                .chipBackground(RG.safeTint)
            } else if purchase.isExpired {
                Text("Expired")
                    .foregroundStyle(RG.textSecondary)
                    .chipBackground(RG.ink.opacity(0.06))
            } else {
                HStack(spacing: 6) {
                    Circle().fill(chipColor).frame(width: 6, height: 6)
                    Text("Return in \(purchase.daysLeft) day\(purchase.daysLeft == 1 ? "" : "s")")
                }
                .foregroundStyle(chipColor)
                .chipBackground(chipTint)
            }
        }
        .font(.rgBody(12, weight: .semibold))
    }

    private var chipColor: Color {
        switch purchase.urgency {
        case .urgent: return RG.urgent
        case .approaching: return RG.approach
        case .safe: return RG.textSecondary
        }
    }
    private var chipTint: Color {
        switch purchase.urgency {
        case .urgent: return RG.urgentTint
        case .approaching: return RG.approachTint
        case .safe: return RG.ink.opacity(0.06)
        }
    }
}
