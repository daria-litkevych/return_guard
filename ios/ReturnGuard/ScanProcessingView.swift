import SwiftUI

/// Brief interstitial shown while Vision runs OCR on the freshly scanned page.
struct ScanProcessingView: View {
    var body: some View {
        VStack(spacing: 18) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.3)
            Text("Reading receipt…")
                .font(.rgBody(14, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RG.ink.ignoresSafeArea())
    }
}
