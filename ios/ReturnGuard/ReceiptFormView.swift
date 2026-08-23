import SwiftUI

/// The editable review screen: shown after OCR (fields pre-filled where we
/// could read them) or for manual entry (fields blank). Same screen either way.
struct ReceiptFormView: View {
    @EnvironmentObject var model: AppModel
    @FocusState private var focusedField: Field?

    enum Field { case product, store, price }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button("Cancel") { model.cancelScan() }
                    .font(.rgBody(15, weight: .medium))
                    .foregroundStyle(RG.accentDeep)

                Text("Check the details").font(.rgHeading(27)).foregroundStyle(RG.ink).padding(.top, 14)
                Text("We filled in what we could read. Tap any field to fix it.")
                    .font(.rgBody(15))
                    .foregroundStyle(RG.textSecondary)
                    .padding(.top, 4)

                VStack(spacing: 0) {
                    formField("Product", text: $model.draft.product, placeholder: "e.g. Sony WH-1000XM6", field: .product)
                    RowDivider().padding(.horizontal, 14)
                    HStack(spacing: 12) {
                        formField("Store", text: $model.draft.store, placeholder: "e.g. Amazon", field: .store)
                        if !model.draft.store.trimmingCharacters(in: .whitespaces).isEmpty {
                            StoreIcon(store: model.draft.store, size: 34, cornerRadius: 10)
                                .padding(.trailing, 14)
                        }
                    }
                    RowDivider().padding(.horizontal, 14)
                    formField("Price", text: $model.draft.priceText, placeholder: "0.00", field: .price, keyboard: .decimalPad)
                    RowDivider().padding(.horizontal, 14)
                    HStack {
                        Text("Purchase date").font(.rgBody(13)).foregroundStyle(RG.textTertiary)
                        Spacer()
                        DatePicker("", selection: $model.draft.purchaseDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                .padding(4)
                .rgCard(padding: 0)
                .padding(.top, 16)

                HStack {
                    Text("Return window").font(.rgBody(15)).foregroundStyle(RG.ink)
                    Spacer()
                    Stepper("\(model.draft.returnWindowDays) days", value: $model.draft.returnWindowDays, in: 7...90, step: 1)
                        .fixedSize()
                }
                .padding(.horizontal, 4)
                .padding(.top, 14)

                HStack {
                    Text("Warranty").font(.rgBody(15)).foregroundStyle(RG.ink)
                    Spacer()
                    Stepper("\(model.draft.warrantyYears) yr", value: $model.draft.warrantyYears, in: 0...10, step: 1)
                        .fixedSize()
                }
                .padding(.horizontal, 4)
                .padding(.top, 10)

                Button {
                    model.saveDraft()
                } label: {
                    Text("Save purchase")
                        .font(.rgHeading(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(model.draft.isValid ? RG.accent : RG.accent.opacity(0.35)))
                }
                .disabled(!model.draft.isValid)
                .padding(.top, 22)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 26)
        }
        .background(RG.background.ignoresSafeArea())
    }

    private func formField(_ label: String, text: Binding<String>, placeholder: String,
                            field: Field, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label).font(.rgBody(13)).foregroundStyle(RG.textTertiary)
            TextField(placeholder, text: text)
                .font(.rgBody(17, weight: .medium))
                .foregroundStyle(RG.ink)
                .keyboardType(keyboard)
                .focused($focusedField, equals: field)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
