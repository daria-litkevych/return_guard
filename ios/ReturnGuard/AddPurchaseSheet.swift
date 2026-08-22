import SwiftUI

struct AddPurchaseSheet: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add a purchase").font(.rgHeading(22)).foregroundStyle(RG.ink)
            Text("No account needed.").font(.rgBody(14)).foregroundStyle(RG.textSecondary).padding(.top, 3)

            VStack(spacing: 10) {
                optionRow(icon: "camera.viewfinder", title: "Scan receipt", subtitle: "Photograph it, we read the details") {
                    model.startScan()
                }
                optionRow(icon: "square.and.arrow.up", title: "Upload", subtitle: "Screenshot, PDF or photo") {}
                optionRow(icon: "square.and.pencil", title: "Enter manually", subtitle: "Four fields, that's it") {}
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .background(RG.background.ignoresSafeArea())
    }

    private func optionRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(RG.accentTint)
                        .frame(width: 42, height: 42)
                    Image(systemName: icon).foregroundStyle(RG.accentDeep)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.rgHeading(17)).foregroundStyle(RG.ink)
                    Text(subtitle).font(.rgBody(13)).foregroundStyle(RG.textSecondary)
                }
                Spacer()
            }
            .padding(16)
            .background(RG.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
