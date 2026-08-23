import SwiftUI
import SwiftData

struct RootView: View {
    @StateObject private var model = AppModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Purchase.purchaseDate, order: .reverse) private var purchases: [Purchase]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Group {
                    switch model.tab {
                    case .home: HomeView()
                    case .purchases: PurchasesView()
                    case .warranties: WarrantiesView()
                    case .settings: SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                BottomBar()
            }
            .background(RG.background.ignoresSafeArea())

            if let purchase = model.selectedPurchase {
                PurchaseDetailView(purchase: purchase)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(2)
            }

            if model.scanPhase == .processing {
                ScanProcessingView()
                    .transition(.opacity)
                    .zIndex(3)
            }
            if model.scanPhase == .review {
                ReceiptFormView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(3)
            }
        }
        .animation(.easeOut(duration: 0.25), value: model.tab)
        .animation(.easeOut(duration: 0.25), value: model.selectedPurchase)
        .animation(.easeOut(duration: 0.25), value: model.scanPhase)
        .sheet(isPresented: $model.showAddSheet) {
            AddPurchaseSheet()
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
                .environmentObject(model)
        }
        .fullScreenCover(isPresented: Binding(
            get: { model.scanPhase == .scanning },
            set: { isPresented in if !isPresented { model.cancelScan() } }
        )) {
            DocumentScannerView(
                onScanned: { image in model.handleScannedImage(image) },
                onCancel: { model.cancelScan() }
            )
            .ignoresSafeArea()
        }
        .environmentObject(model)
        .onAppear {
            model.modelContext = modelContext
            model.sync(purchases)
            model.seedIfNeeded()
            NotificationManager.syncReminders(for: purchases)
        }
        .onChange(of: purchases) { _, newValue in
            model.sync(newValue)
            NotificationManager.syncReminders(for: newValue)
        }
    }
}

private struct BottomBar: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        VStack(spacing: 12) {
            Button {
                model.openAddSheet()
            } label: {
                Text("Add purchase")
                    .font(.rgHeading(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Capsule().fill(RG.accent))
                    .shadow(color: RG.accent.opacity(0.35), radius: 10, x: 0, y: 6)
            }

            HStack {
                tabButton(.home, systemImage: "house.fill", label: "Home")
                tabButton(.purchases, systemImage: "bag.fill", label: "Purchases")
                tabButton(.warranties, systemImage: "checkmark.shield.fill", label: "Warranty")
                tabButton(.settings, systemImage: "line.3.horizontal", label: "Settings")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Rectangle().fill(RG.divider).frame(height: 1) }
    }

    private func tabButton(_ tab: AppTab, systemImage: String, label: String) -> some View {
        let selected = model.tab == tab
        return Button {
            model.tab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: selected ? .semibold : .regular))
                Text(label)
                    .font(.rgBody(11, weight: selected ? .semibold : .medium))
            }
            .foregroundStyle(selected ? RG.accent : RG.textTertiary)
            .frame(maxWidth: .infinity)
        }
    }
}
