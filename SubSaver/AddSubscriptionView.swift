import SwiftUI

struct AddSubscriptionView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // Settings ile paylaşılan değerler (store üzerinden)
    private var defaultCurrencyCode: String {
        store.defaultCurrency
    }

    private var globalReminderDays: Int {
        store.reminderDaysBefore
    }

    // MARK: - Form state

    @State private var selectedService: SubscriptionService? = nil
    @State private var showServicePicker = false

    @State private var name: String = ""
    @State private var priceText: String = ""
    @State private var currencyCode: String = ""

    @State private var cycle: BillingCycle = .monthly
    @State private var renewalDate: Date = Date()

    @State private var notifyEnabled: Bool = true
    @State private var notifyDaysBefore: Int = 3
    @State private var notifyHour: Int = 9
    @State private var notifyMinute: Int = 0

    @State private var showValidationError: Bool = false

    // MARK: - Init-like ayarlar

    private func syncDefaultsIfNeeded() {
        // Varsayılan para birimi
        if currencyCode.isEmpty {
            currencyCode = defaultCurrencyCode
        }

        // Varsayılan hatırlatma günleri yalnızca ilk açılışta 3 ise ayarla
        if notifyDaysBefore == 3 {
            notifyDaysBefore = globalReminderDays
        }

        // Servis seçildiyse ismi doldur
        if let service = selectedService, name.isEmpty {
            name = service.displayName
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                background
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                ScrollView {
                    VStack(spacing: 20) {
                        header

                        serviceSection
                        detailsSection
                        dateSection
                        notificationSection

                        Spacer(minLength: 20)

                        primaryButton
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Text("common.cancel", bundle: .main)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { save() } label: {
                        Text("common.save", bundle: .main)
                    }
                    .fontWeight(.semibold)
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
            .onAppear {
                syncDefaultsIfNeeded()
            }
            .alert(Text("addSubscription.validation.error", bundle: .main), isPresented: $showValidationError) {
                Button { } label: {
                    Text("common.ok", bundle: .main)
                }
            }
        }
        // Hizmet seçme sheet'i
        .sheet(isPresented: $showServicePicker) {
            ServicePickerSheet(
                selectedService: Binding(
                    get: { selectedService },
                    set: { newValue in
                        selectedService = newValue
                        if let s = newValue {
                            // Seçildiğinde isim otomatik dolsun
                            if name.isEmpty {
                                name = s.displayName
                            }
                            if currencyCode.isEmpty {
                                currencyCode = defaultCurrencyCode
                            }
                        }
                    }
                )
            )
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: colorScheme == .dark
            ? [Color(red: 0.08, green: 0.12, blue: 0.24),
               Color(red: 0.02, green: 0.06, blue: 0.16)]
            : [Color(red: 0.95, green: 0.97, blue: 1.0),
               Color(red: 0.88, green: 0.93, blue: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("addSubscription.title", bundle: .main)
                .font(.title2.weight(.bold))
            Text("addSubscription.subtitle", bundle: .main)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - ABONELİK HİZMETİ kartı

    private var serviceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("addSubscription.serviceSection", bundle: .main)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                // Sol taraf: seçilen hizmet / placeholder
                HStack(spacing: 12) {
                    if let service = selectedService {
                        // Logo
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.secondarySystemBackground).opacity(0.8))
                                .frame(width: 46, height: 46)
                            
                            Image(service.assetName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 46, height: 46)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(service.displayName)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                            Text("addSubscription.service.selected", bundle: .main)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary.opacity(0.85))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("addSubscription.service.selected", bundle: .main)
                                .font(.subheadline.weight(.semibold))
                            Text("addSubscription.service.notSelected", bundle: .main)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Sağ taraf: "Bir hizmet seçin" butonu
                Button {
                    showServicePicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.and.123")
                            .font(.system(size: 14, weight: .semibold))
                        Text("addSubscription.service.select", bundle: .main)
                            .font(.footnote.weight(.semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.18))
                    )
                    .foregroundColor(.blue)
                }
            }
        }
        .glassCard()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Detaylar

    /// İsim + fiyat + para birimi + döngü
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("addSubscription.details", bundle: .main)
                .font(.subheadline.weight(.semibold))
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

            // İsim
            TextField(text: $name, prompt: Text("addSubscription.namePlaceholder", bundle: .main)) {
                Text("addSubscription.namePlaceholder", bundle: .main)
            }
            .textInputAutocapitalization(.words)
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                Divider().background(Color.primary.opacity(0.12))
            }

            // Fiyat + para birimi
            HStack(spacing: 12) {
                TextField(text: $priceText, prompt: Text("addSubscription.price", bundle: .main)) {
                    Text("addSubscription.price", bundle: .main)
                }
                .keyboardType(.decimalPad)
                .padding(.vertical, 8)
                .overlay(alignment: .bottom) {
                    Divider().background(Color.primary.opacity(0.12))
                }

                Menu {
                    ForEach(["TRY","USD","EUR","GBP","JPY","CHF","AUD","CAD"], id: \.self) { code in
                        Button(code) { currencyCode = code }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(currencyCode.isEmpty ? defaultCurrencyCode : currencyCode)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground).opacity(0.9))
                    .clipShape(Capsule())
                }
            }

            // Döngü
            Picker(selection: $cycle) {
                Text("cycle.weekly", bundle: .main).tag(BillingCycle.weekly)
                Text("cycle.monthly", bundle: .main).tag(BillingCycle.monthly)
                Text("cycle.yearly", bundle: .main).tag(BillingCycle.yearly)
            } label: {
                Text("cycle.title", bundle: .main)
            }
            .pickerStyle(.segmented)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .glassCard()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Yenileme tarihi

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("addSubscription.renewalDate", bundle: .main)
                .font(.subheadline.weight(.semibold))

            DatePicker(selection: $renewalDate, displayedComponents: .date) {
                Text("addSubscription.renewalDate", bundle: .main)
            }
            .datePickerStyle(.compact)
        }
        .glassCard()
    }

    // MARK: - Bildirimler

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("addSubscription.notifications.title", bundle: .main)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Toggle("", isOn: $notifyEnabled)
                    .labelsHidden()
            }

            if notifyEnabled {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("addSubscription.notifications.daysBefore", bundle: .main)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(String(format: NSLocalizedString("addSubscription.notifications.daysBeforeValue", bundle: .main, comment: ""), notifyDaysBefore))
                            .font(.caption.weight(.semibold))
                    }

                    Spacer()

                    Stepper("", value: $notifyDaysBefore, in: 0...30)
                        .labelsHidden()
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("addSubscription.notifications.time", bundle: .main)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%02d:%02d", notifyHour, notifyMinute))
                            .font(.caption.weight(.semibold))
                    }

                    Spacer()

                    DatePicker(
                        "",
                        selection: Binding<Date>(
                            get: {
                                var comps = Calendar.current.dateComponents([.year,.month,.day], from: Date())
                                comps.hour = notifyHour
                                comps.minute = notifyMinute
                                return Calendar.current.date(from: comps) ?? Date()
                            },
                            set: { newDate in
                                let comps = Calendar.current.dateComponents([.hour,.minute], from: newDate)
                                notifyHour = comps.hour ?? 9
                                notifyMinute = comps.minute ?? 0
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
            }
        }
        .glassCard()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Primary Button

    private var primaryButton: some View {
        Button(action: save) {
            Text("home.addSubscription", bundle: .main)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
        }
    }

    // MARK: - Save

    private func save() {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedName.isEmpty,
              let price = Double(priceText.replacingOccurrences(of: ",", with: ".")) else {
            showValidationError = true
            return
        }

        let code = currencyCode.isEmpty ? defaultCurrencyCode : currencyCode

        let sub = Subscription(
            name: normalizedName,
            price: price,
            currencyCode: code,
            cycle: cycle,
            renewalDate: renewalDate,
            lastUsedDate: nil,
            aiDecision: .keep,
            overrideDecision: nil,
            notifyEnabled: notifyEnabled,
            notifyDaysBefore: notifyEnabled ? notifyDaysBefore : 0,
            notifyHour: notifyHour,
            notifyMinute: notifyMinute,
            service: selectedService
        )

        store.add(sub)
        dismiss()
    }
}
