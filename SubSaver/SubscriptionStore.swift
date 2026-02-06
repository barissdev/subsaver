import Foundation

/// Abonelikleri ve ayarları tutan ana store.
final class SubscriptionStore: ObservableObject {
    
    // MARK: - Published state
    
    @Published var items: [Subscription] = [] {
        didSet { save() }
    }
    
    /// Uygulamada gösterilecek varsayılan para birimi (TRY, USD, EUR ...)
    @Published var defaultCurrency: String {
        didSet {
            save()
            Task { await loadExchangeRates() }
        }
    }
    
    /// Kur sözlüğü: ["USD": 1.0, "EUR": 0.92, "TRY": 34.0, ...]
    @Published var fxRates: [String: Double] {
        didSet { save() }
    }
    
    /// Bildirimler global olarak açık mı?
    @Published var notificationsEnabled: Bool {
        didSet {
            save()
            Task { await rescheduleAllReminders() }
        }
    }
    
    /// Yenilemeden kaç gün önce hatırlatılacak?
    @Published var reminderDaysBefore: Int {
        didSet {
            save()
            Task { await rescheduleAllReminders() }
        }
    }
    
    // MARK: - Init / Persistence
    
    private let storageURL: URL
    private let iCloudStore = NSUbiquitousKeyValueStore.default
    
    init() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        storageURL = docs.appendingPathComponent("subscriptions.json")
        
        // Varsayılan değerler
        self.defaultCurrency = Locale.current.currency?.identifier ?? "TRY"
        self.fxRates = ["USD": 1.0]
        self.notificationsEnabled = true
        self.reminderDaysBefore = 3
        
        load()
        
        // iCloud değişikliklerini dinle
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore,
            queue: .main
        ) { [weak self] _ in
            self?.loadFromiCloud()
        }
        
        // Uygulama açıldığında kurları yükle
        Task { await loadExchangeRates() }
    }
    
    private struct StoredState: Codable {
        var items: [Subscription]
        var defaultCurrency: String
        var fxRates: [String: Double]
        var notificationsEnabled: Bool
        var reminderDaysBefore: Int
    }
    
    private func load() {
        // Önce iCloud'dan yükle, yoksa local'den
        if let iCloudData = iCloudStore.data(forKey: "subscriptions"), !iCloudData.isEmpty {
            loadFromiCloud()
        } else {
            loadFromLocal()
        }
    }
    
    private func loadFromiCloud() {
        guard let data = iCloudStore.data(forKey: "subscriptions") else { return }
        do {
            let decoded = try JSONDecoder().decode(StoredState.self, from: data)
            self.items = decoded.items
            self.defaultCurrency = decoded.defaultCurrency
            self.fxRates = decoded.fxRates
            self.notificationsEnabled = decoded.notificationsEnabled
            self.reminderDaysBefore = decoded.reminderDaysBefore
            
            // Local'e de kaydet
            saveToLocal(data: data)
        } catch {
            print("Load from iCloud error:", error)
            loadFromLocal()
        }
    }
    
    private func loadFromLocal() {
        do {
            let data = try Data(contentsOf: storageURL)
            let decoded = try JSONDecoder().decode(StoredState.self, from: data)
            self.items = decoded.items
            self.defaultCurrency = decoded.defaultCurrency
            self.fxRates = decoded.fxRates
            self.notificationsEnabled = decoded.notificationsEnabled
            self.reminderDaysBefore = decoded.reminderDaysBefore
        } catch {
            // İlk açılışta dosya yoksa sorun değil.
            print("Load store error:", error)
        }
    }
    
    private func save() {
        let state = StoredState(
            items: items,
            defaultCurrency: defaultCurrency,
            fxRates: fxRates,
            notificationsEnabled: notificationsEnabled,
            reminderDaysBefore: reminderDaysBefore
        )
        
        do {
            let data = try JSONEncoder().encode(state)
            
            // Hem local hem iCloud'a kaydet
            saveToLocal(data: data)
            saveToiCloud(data: data)
        } catch {
            print("Save store error:", error)
        }
    }
    
    private func saveToLocal(data: Data) {
        do {
            try data.write(to: storageURL, options: [.atomic])
        } catch {
            print("Save to local error:", error)
        }
    }
    
    private func saveToiCloud(data: Data) {
        iCloudStore.set(data, forKey: "subscriptions")
        iCloudStore.synchronize()
    }
    
    // MARK: - Para birimi & toplamlar
    
    /// Varsayılan para biriminde aylık toplam.
    var totalMonthlyInDefaultCurrency: Double {
        monthlyTotal(in: defaultCurrency)
    }
    
    /// Varsayılan para biriminde yıllık toplam.
    var totalYearlyInDefaultCurrency: Double {
        yearlyTotal(in: defaultCurrency)
    }
    
    /// Varsayılan para biriminde potansiyel aylık tasarruf
    /// (karar = .cancel olan abonelikler).
    var potentialMonthlySavingsInDefaultCurrency: Double {
        items.reduce(0) { partial, sub in
            let decision = sub.overrideDecision ?? sub.aiDecision
            guard decision == .cancel else { return partial }
            return partial + monthlyAmount(for: sub, in: defaultCurrency)
        }
    }
    
    /// Verilen hedef para biriminde aylık toplam.
    func monthlyTotal(in targetCurrency: String) -> Double {
        items.reduce(0) { partial, sub in
            partial + monthlyAmount(for: sub, in: targetCurrency)
        }
    }
    
    /// Verilen hedef para biriminde yıllık toplam.
    func yearlyTotal(in targetCurrency: String) -> Double {
        monthlyTotal(in: targetCurrency) * 12.0
    }
    
    /// Bir aboneliğin *aylık bazdaki* tutarını hedef para biriminde döndürür.
    private func monthlyAmount(for sub: Subscription,
                               in targetCurrency: String) -> Double {
        // Önce aboneliği kendi para biriminde aylığa çevir
        let baseMonthly: Double
        switch sub.cycle {
        case .weekly:
            baseMonthly = sub.price * (52.0 / 12.0)
        case .monthly:
            baseMonthly = sub.price
        case .yearly:
            baseMonthly = sub.price / 12.0
        }
        
        // Sonra döviz çevir
        return convert(amount: baseMonthly,
                       from: sub.currencyCode,
                       to: targetCurrency)
    }
    
    /// Genel döviz çevirme fonksiyonu.
    func convert(amount: Double,
                 from fromCode: String,
                 to toCode: String) -> Double {
        let from = fromCode.uppercased()
        let to   = toCode.uppercased()
        
        if from == to { return amount }
        
        let fromRate = fxRates[from] ?? 1.0
        let toRate   = fxRates[to] ?? 1.0
        
        // Tüm kurlar USD base'e göre olduğu için:
        // 1 USD = fromRate * fromCurrency
        // 1 USD = toRate * toCurrency
        // amount (fromCurrency) -> USD -> toCurrency
        return amount / fromRate * toRate
    }
    
    // MARK: - Exchange Rates
    
    /// API'den güncel döviz kurlarını yükler
    func loadExchangeRates() async {
        let supportedCurrencies = ["USD", "EUR", "TRY", "GBP", "CHF", "JPY"]
        let currenciesToFetch = supportedCurrencies.filter { $0 != "USD" }
        let currenciesList = currenciesToFetch.joined(separator: ",")
        
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=USD&to=\(currenciesList)") else {
            print("❌ Invalid URL for exchange rates")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
            
            // USD base olduğu için USD = 1.0
            var rates = response.rates
            rates["USD"] = 1.0
            
            await MainActor.run {
                self.fxRates = rates
            }
        } catch {
            print("❌ Exchange rate error: \(error.localizedDescription)")
            // Hata durumunda en azından USD = 1.0 olduğundan emin ol
            await MainActor.run {
                if self.fxRates.isEmpty {
                    self.fxRates = ["USD": 1.0]
                }
            }
        }
    }
    
    private struct ExchangeRateResponse: Codable {
        let rates: [String: Double]
    }
    
    // MARK: - CRUD
    
    func add(_ sub: Subscription) {
        var s = sub
        if s.currencyCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            s.currencyCode = defaultCurrency
        }
        items.insert(s, at: 0)
        
        Task {
            await scheduleReminderIfNeeded(for: s)
        }
    }
    
    func update(_ sub: Subscription) {
        guard let idx = items.firstIndex(where: { $0.id == sub.id }) else { return }
        items[idx] = sub
        
        Task {
            await NotificationScheduler.cancelReminder(for: sub)
            await scheduleReminderIfNeeded(for: sub)
        }
    }
    
    func delete(at offsets: IndexSet) {
        let deletedSubs = offsets.map { items[$0] }
        items.remove(atOffsets: offsets)
        
        Task {
            for sub in deletedSubs {
                await NotificationScheduler.cancelReminder(for: sub)
            }
        }
    }
    
    // MARK: - Yenileme tarihleri (Home / Statistics için)
    
    /// Bugün yenilenecek abonelikler.
    var renewingToday: [Subscription] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return items.filter { cal.isDate($0.renewalDate, inSameDayAs: today) }
    }
    
    /// Tarihi geçmiş (gecikmiş) abonelikler.
    var overdueRenewals: [Subscription] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return items
            .filter { $0.renewalDate < today }
            .sorted { $0.renewalDate < $1.renewalDate }
    }
    
    /// Önümüzdeki X gün içinde yenilenecek abonelikler.
    func upcomingRenewals(within days: Int) -> [Subscription] {
        let now = Date()
        guard let target = Calendar.current.date(byAdding: .day,
                                                 value: days,
                                                 to: now) else {
            return []
        }
        
        return items
            .filter { $0.renewalDate >= now && $0.renewalDate <= target }
            .sorted { $0.renewalDate < $1.renewalDate }
    }
    
    // MARK: - Bildirimler
    
    /// Tüm abonelikler için hatırlatmaları yeniden oluşturur
    func rescheduleAllReminders() async {
        // Ayarlardan bildirimler kapalıysa hepsini iptal et
        if !notificationsEnabled {
            await NotificationScheduler.cancelAll()
            return
        }
        
        // Açık olan her abonelik için yeniden planla
        for sub in items where sub.notifyEnabled {
            await NotificationScheduler.scheduleReminder(
                for: sub,
                daysBefore: sub.notifyDaysBefore,
                hour: sub.notifyHour,
                minute: sub.notifyMinute
            )
        }
    }
    
    /// Tek bir abonelik için gerekiyorsa hatırlatma planlar
    private func scheduleReminderIfNeeded(for sub: Subscription) async {
        guard notificationsEnabled, sub.notifyEnabled else { return }
        
        await NotificationScheduler.scheduleReminder(
            for: sub,
            daysBefore: sub.notifyDaysBefore,
            hour: sub.notifyHour,
            minute: sub.notifyMinute
        )
    }
}
