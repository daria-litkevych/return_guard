import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: AppModel
    @EnvironmentObject var store: StoreManager
    @AppStorage(NotificationManager.notificationsEnabledKey) private var notificationsOn = true
    @State private var showDeleteConfirm = false
    @State private var showNotificationsDeniedAlert = false
    @State private var isRestoring = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings").font(.rgHeading(27)).foregroundStyle(RG.ink)

                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        Circle().fill(RG.accentTint).frame(width: 40, height: 40)
                        Image(systemName: "lock.shield").foregroundStyle(RG.accent)
                    }
                    Text("Your purchases are yours").font(.rgHeading(19)).foregroundStyle(RG.ink)
                    Text("No bank account. No financial access. Receipts stay private, and you can export or delete everything at any time.")
                        .font(.rgBody(14))
                        .foregroundStyle(RG.textSecondary)
                    Text("Read our privacy promise").font(.rgBody(14, weight: .semibold)).foregroundStyle(RG.accentDeep)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .rgCard(padding: 20, radius: 22)
                .padding(.top, 18)

                Text("Reminders").font(.rgHeading(15)).foregroundStyle(RG.ink)
                    .padding(.top, 22).padding(.bottom, 10)
                VStack(spacing: 0) {
                    HStack {
                        Text("Notifications").font(.rgBody(15)).foregroundStyle(RG.ink)
                        Spacer()
                        Toggle("", isOn: $notificationsOn).labelsHidden().tint(RG.accent)
                            .onChange(of: notificationsOn) { _, isOn in
                                Task {
                                    if isOn {
                                        let granted = await NotificationManager.requestAuthorization()
                                        if !granted {
                                            notificationsOn = false
                                            showNotificationsDeniedAlert = true
                                            return
                                        }
                                    }
                                    NotificationManager.syncReminders(for: model.purchases)
                                }
                            }
                    }
                    .padding(12)
                    RowDivider().padding(.horizontal, 12)
                    HStack {
                        Text("Default reminder timing").font(.rgBody(15)).foregroundStyle(RG.ink)
                        Spacer()
                        Text("7 days before").font(.rgBody(15)).foregroundStyle(RG.textTertiary)
                    }
                    .padding(12)
                }
                .padding(4)
                .rgCard(padding: 0)

                Text("Account & data").font(.rgHeading(15)).foregroundStyle(RG.ink)
                    .padding(.top, 22).padding(.bottom, 10)
                VStack(spacing: 0) {
                    settingsRow("Account")
                    RowDivider().padding(.horizontal, 12)
                    Button {
                        if !store.isPremium { model.showPaywall = true }
                    } label: {
                        HStack {
                            Text("Subscription").font(.rgBody(15)).foregroundStyle(RG.ink)
                            Spacer()
                            Text(subscriptionLabel).font(.rgBody(14, weight: .medium)).foregroundStyle(RG.accentDeep)
                        }
                        .padding(12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    RowDivider().padding(.horizontal, 12)
                    Button {
                        isRestoring = true
                        Task {
                            await store.restore()
                            isRestoring = false
                        }
                    } label: {
                        HStack {
                            Text("Restore purchases").font(.rgBody(15)).foregroundStyle(RG.ink)
                            Spacer()
                            if isRestoring { ProgressView() }
                        }
                        .padding(12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isRestoring)
                    RowDivider().padding(.horizontal, 12)

                    ShareLink(item: model.exportURL()) {
                        HStack {
                            Text("Export my data").font(.rgBody(15)).foregroundStyle(RG.ink)
                            Spacer()
                            Image(systemName: "square.and.arrow.up").foregroundStyle(RG.textTertiary)
                        }
                        .padding(12)
                        .contentShape(Rectangle())
                    }

                    RowDivider().padding(.horizontal, 12)
                    settingsRow("Help")
                    RowDivider().padding(.horizontal, 12)
                    settingsRow("About")
                    RowDivider().padding(.horizontal, 12)

                    Button {
                        showDeleteConfirm = true
                    } label: {
                        HStack {
                            Text("Delete all data").font(.rgBody(15)).foregroundStyle(RG.urgent)
                            Spacer()
                        }
                        .padding(12)
                        .contentShape(Rectangle())
                    }
                }
                .padding(4)
                .rgCard(padding: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 26)
        }
        .confirmationDialog("Delete everything?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) { model.deleteAllData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes every tracked purchase and warranty. This can't be undone.")
        }
        .alert("Notifications are off", isPresented: $showNotificationsDeniedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Turn on notifications for ReturnGuard in iOS Settings to get return reminders.")
        }
    }

    private var subscriptionLabel: String {
        guard store.isPremium else { return "Free plan" }
        return "Premium · \(store.activePlan?.title.lowercased() ?? "")"
    }

    private func settingsRow(_ text: String, color: Color = RG.ink) -> some View {
        HStack {
            Text(text).font(.rgBody(15)).foregroundStyle(color)
            Spacer()
        }
        .padding(12)
    }
}
