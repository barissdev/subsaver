import SwiftUI

struct SubscriptionDetailView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.dismiss) private var dismiss

    // Düzenlediğimiz aboneliğin kopyası
    @State private var draft: Subscription
    // Kullanıcının seçtiği karar (Aktif / İncele / Kapalı)
    @State private var decision: AiDecision

    // Varsayılan para birimi (Settings’ten seçilen)
    private var defaultCode: String {
        store.defaultCurrency.uppercased()
    }

    // MARK: - Init

    init(sub: Subscription) {
        _draft = State(initialValue: sub)
        _decision = State(initialValue: sub.overrideDecision ?? sub.aiDecision)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                ScrollView {
                    VStack(spacing: 20) {

                        costSummaryCard
                        detailsCard
                        notificationCard
                        decisionCard

                        Spacer(minLength: 12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(draft.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Text("common.cancel", bundle: .main)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { save() } label: {
                        Text("common.save", bundle: .main)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("common.ok", bundle: .main)
                    }
                }
            }
        }
    }

    // MARK: - Kartlar

    /// Ücret özet kartı (aylık / yıllık, varsayılan para biriminde)
    private var costSummaryCard: some View {
        let baseMonthly = monthlyAmountInSourceCurrency
        let convertedMonthly = store.convert(amount: baseMonthly,
                                             from: draft.currencyCode,
                                             to: store.defaultCurrency) 
        let convertedYearly = convertedMonthly * 12

        return VStack(alignment: .leading, spacing: 16) {
            Text("subscriptionDetail.costSummary", bundle: .main)
                .font(.headline)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("subscriptionDetail.monthlyEstimate", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(convertedMonthly,
                         format: .currency(code: defaultCode))
                        .font(.system(size: 26, weight: .bold))
                        .minimumScaleFactor(0.7)

                    Text("subscriptionDetail.inDefaultCurrency", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 16)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("subscriptionDetail.yearlyTotal", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(convertedYearly,
                         format: .currency(code: defaultCode))
                        .font(.headline.weight(.semibold))

                    Text(draft.currencyCode.uppercased())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .glassCard()
    }

    /// Temel bilgiler (isim, fiyat, döngü, yenileme tarihi)
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("subscriptionDetail.subscriptionInfo", bundle: .main)
                .font(.headline)

            TextField(text: $draft.name, prompt: Text("common.name", bundle: .main)) {
                Text("common.name", bundle: .main)
            }
            .textInputAutocapitalization(.words)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("subscriptionDetail.price", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    TextField(value: $draft.price, format: .number, prompt: Text("subscriptionDetail.price", bundle: .main)) {
                         Text("subscriptionDetail.price", bundle: .main)
                    }
                    .keyboardType(.decimalPad)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("subscriptionDetail.currency", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(draft.currencyCode.uppercased())
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("subscriptionDetail.paymentCycle", bundle: .main)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Picker(selection: $draft.cycle) {
                    ForEach(BillingCycle.allCases) { cycle in
                        Text(label(for: cycle), bundle: .main).tag(cycle)
                    }
                } label: {
                    Text("cycle.title", bundle: .main)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("subscriptionDetail.renewalDate", bundle: .main)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                DatePicker(
                    "",
                    selection: $draft.renewalDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
            }
        }
        .glassCard()
    }

    /// Bildirim ayar kartı
    private var notificationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("subscriptionDetail.notifications", bundle: .main)
                .font(.headline)

            Toggle(isOn: $draft.notifyEnabled) {
                Text("subscriptionDetail.sendNotification", bundle: .main)
            }

            if draft.notifyEnabled {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("subscriptionDetail.daysBefore", bundle: .main)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(String(format: NSLocalizedString("subscriptionDetail.daysBeforeValue", bundle: .main, comment: ""), draft.notifyDaysBefore))
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Stepper(
                        "",
                        value: $draft.notifyDaysBefore,
                        in: 0...30
                    )
                    .labelsHidden()
                }
            }
        }
        .glassCard()
    }

    /// Aktif / İncele / Kapalı karar kartı
    private var decisionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("subscriptionDetail.status", bundle: .main)
                .font(.headline)

            Picker("", selection: $decision) {
                Text("subscriptionDetail.active", bundle: .main).tag(AiDecision.keep)
                Text("subscriptionDetail.review", bundle: .main).tag(AiDecision.review)
                Text("subscriptionDetail.cancelled", bundle: .main).tag(AiDecision.cancel)
            }
            .pickerStyle(.segmented)

            Text("subscriptionDetail.statusNote", bundle: .main)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .glassCard()
    }

    // MARK: - Helpers

    /// Aboneliğin kendi döngüsünden **aylık** tutarı (kendi para biriminde)
    private var monthlyAmountInSourceCurrency: Double {
        switch draft.cycle {
        case .weekly:
            // 52 hafta / 12 ay ≈ aylık
            return draft.price * (52.0 / 12.0)
        case .monthly:
            return draft.price
        case .yearly:
            return draft.price / 12.0
        }
    }

    private func label(for cycle: BillingCycle) -> LocalizedStringKey {
        switch cycle {
        case .weekly:  return "cycle.weekly"
        case .monthly: return "cycle.monthly"
        case .yearly:  return "cycle.yearly"
        }
    }

    private func save() {
        // Kararı kayda uygula
        draft.aiDecision = decision
        draft.overrideDecision = decision

        store.update(draft)
        dismiss()
    }
}
