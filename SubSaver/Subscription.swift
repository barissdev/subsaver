import Foundation

enum BillingCycle: String, Codable, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"

    var id: String { rawValue }
}

enum AiDecision: String, Codable, CaseIterable, Identifiable {
    case keep = "Keep"
    case review = "Review"
    case cancel = "Cancel"

    var id: String { rawValue }
}

struct Subscription: Identifiable, Codable, Hashable {
    var id: UUID = UUID()

    var name: String
    var price: Double
    var cycle: BillingCycle
    var renewalDate: Date

    var lastUsedDate: Date? = nil

    // AI decision
    var aiDecision: AiDecision = .review
    var overrideDecision: AiDecision? = nil

    // Currency (for display)
    var currencyCode: String = (Locale.current.currency?.identifier ?? "USD")

    // Per-sub notifications
    var notifyEnabled: Bool = true
    var notifyDaysBefore: Int = 3
    var notifyHour: Int = 9
    var notifyMinute: Int = 0

    // Servis logoları (Netflix, Spotify vs.)
    var service: SubscriptionService? = nil

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price
        case cycle
        case renewalDate
        case lastUsedDate
        case aiDecision
        case overrideDecision
        case currencyCode
        case notifyEnabled
        case notifyDaysBefore
        case notifyHour
        case notifyMinute
        case service           // 👈 logo bilgisini de JSON’a yaz
    }

    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        currencyCode: String = (Locale.current.currency?.identifier ?? "USD"),
        cycle: BillingCycle,
        renewalDate: Date,
        lastUsedDate: Date? = nil,
        aiDecision: AiDecision = .keep,
        overrideDecision: AiDecision? = nil,
        notifyEnabled: Bool = true,
        notifyDaysBefore: Int = 3,
        notifyHour: Int = 9,
        notifyMinute: Int = 0,
        service: SubscriptionService? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.currencyCode = currencyCode
        self.cycle = cycle
        self.renewalDate = renewalDate
        self.lastUsedDate = lastUsedDate
        self.aiDecision = aiDecision
        self.overrideDecision = overrideDecision
        self.notifyEnabled = notifyEnabled
        self.notifyDaysBefore = notifyDaysBefore
        self.notifyHour = notifyHour
        self.notifyMinute = notifyMinute
        self.service = service
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        price = try c.decode(Double.self, forKey: .price)
        cycle = try c.decode(BillingCycle.self, forKey: .cycle)
        renewalDate = try c.decode(Date.self, forKey: .renewalDate)

        lastUsedDate = try c.decodeIfPresent(Date.self, forKey: .lastUsedDate)

        aiDecision = try c.decodeIfPresent(AiDecision.self, forKey: .aiDecision) ?? .review
        overrideDecision = try c.decodeIfPresent(AiDecision.self, forKey: .overrideDecision)

        currencyCode = try c.decodeIfPresent(String.self, forKey: .currencyCode)
            ?? (Locale.current.currency?.identifier ?? "USD")

        notifyEnabled = try c.decodeIfPresent(Bool.self, forKey: .notifyEnabled) ?? true
        notifyDaysBefore = try c.decodeIfPresent(Int.self, forKey: .notifyDaysBefore) ?? 3
        notifyHour = try c.decodeIfPresent(Int.self, forKey: .notifyHour) ?? 9
        notifyMinute = try c.decodeIfPresent(Int.self, forKey: .notifyMinute) ?? 0

        // Eski kayıtlarda yoksa sorun olmasın
        service = try c.decodeIfPresent(SubscriptionService.self, forKey: .service)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)

        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(price, forKey: .price)
        try c.encode(cycle, forKey: .cycle)
        try c.encode(renewalDate, forKey: .renewalDate)
        try c.encodeIfPresent(lastUsedDate, forKey: .lastUsedDate)

        try c.encode(aiDecision, forKey: .aiDecision)
        try c.encodeIfPresent(overrideDecision, forKey: .overrideDecision)
        try c.encode(currencyCode, forKey: .currencyCode)

        try c.encode(notifyEnabled, forKey: .notifyEnabled)
        try c.encode(notifyDaysBefore, forKey: .notifyDaysBefore)
        try c.encode(notifyHour, forKey: .notifyHour)
        try c.encode(notifyMinute, forKey: .notifyMinute)

        try c.encodeIfPresent(service, forKey: .service)  // 👈 logo bilgisini yaz
    }
}

