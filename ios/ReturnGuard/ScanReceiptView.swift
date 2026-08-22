import SwiftUI

struct ScanReceiptView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            Button("Cancel") { model.cancelScan() }
                .font(.rgBody(15, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.top, 8)

            Spacer()

            Text("Fit the receipt in the frame")
                .font(.rgBody(14))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.bottom, 20)

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        Text("RECEIPT PHOTO")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.45))
                    )
                ViewfinderCorners()
            }
            .frame(width: 250, height: 350)

            Spacer()

            Text("Reading receipt…")
                .font(.rgBody(14, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(Capsule().fill(.white.opacity(0.14)))
                .padding(.bottom, 24)

            HStack {
                Text("Upload").font(.rgBody(14)).foregroundStyle(.white.opacity(0.65)).frame(maxWidth: .infinity)
                Button { model.shootNow() } label: {
                    Circle().stroke(.white, lineWidth: 3).frame(width: 66, height: 66)
                }
                Text("Manual").font(.rgBody(14)).foregroundStyle(.white.opacity(0.65)).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 30)
        }
        .background(RG.ink.ignoresSafeArea())
    }
}

private struct ViewfinderCorners: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height, len: CGFloat = 30
            Path { path in
                path.move(to: CGPoint(x: 0, y: len))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: len, y: 0))

                path.move(to: CGPoint(x: w - len, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: len))

                path.move(to: CGPoint(x: 0, y: h - len))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: len, y: h))

                path.move(to: CGPoint(x: w - len, y: h))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: w, y: h - len))
            }
            .stroke(Color.white, lineWidth: 3)
        }
    }
}
