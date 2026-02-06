import SwiftUI

struct EditSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: SubscriptionStore

    @State private var sub: Subscription
    @State private var priceText: String

    init(sub: Subscription) {
        _sub = State(initialValue: sub)
        _priceText = State(initialValue: String(sub.price))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    TextField("Name", text: $sub.name)

                    TextField("Price", text: $priceText)
                        .keyboardType(.decimalPad)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        }

                    Picker("Billing cycle", selection: $sub.cycle) {
                        ForEach(BillingCycle.allCases) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }

                    DatePicker("Renewal date", selection: $sub.renewalDate, displayedComponents: .date)

                    Toggle("I know last used date", isOn: hasLastUsed)

                    if hasLastUsed.wrappedValue {
                        DatePicker(
                            "Last used",
                            selection: Binding(
                                get: { sub.lastUsedDate ?? Date() },
                                set: { sub.lastUsedDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }

                Section("Decision") {
                    Picker("Override decision", selection: $sub.overrideDecision) {
                        Text("Auto").tag(AiDecision?.none)
                        Text("Keep").tag(AiDecision?.some(.keep))
                        Text("Review").tag(AiDecision?.some(.review))
                        Text("Cancel").tag(AiDecision?.some(.cancel))
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private var hasLastUsed: Binding<Bool> {
        Binding(
            get: { sub.lastUsedDate != nil },
            set: { newValue in
                if newValue == false {
                    sub.lastUsedDate = nil
                } else if sub.lastUsedDate == nil {
                    sub.lastUsedDate = Date()
                }
            }
        )
    }

    private var canSave: Bool {
        !sub.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Double(priceText) != nil
    }

    private func save() {
        guard let price = Double(priceText) else { return }
        sub.price = price
        store.update(sub)
        dismiss()
    }
}
