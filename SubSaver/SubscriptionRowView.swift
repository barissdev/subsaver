import SwiftUI

struct SubscriptionRowView: View {
    let sub: Subscription

    var body: some View {
        HStack(spacing: 12) {
            icon

            VStack(alignment: .leading, spacing: 6) {
                // Üst satır: isim + döngü etiketi
                HStack(alignment: .firstTextBaseline) {
                    Text(sub.service?.displayName ?? sub.name)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(cycleDisplayKey, bundle: .main)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }

                // Alt satır: fiyat / döngü + çan
                HStack(spacing: 6) {
                    pricePerCycleText
                        .font(.subheadline)
                    if sub.notifyEnabled {
                        Image(systemName: "bell.fill")
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            statusBadge
        }
        .padding(.vertical, 4)
    }

    // MARK: - Icon (logo veya fallback)

    private var icon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.thinMaterial)
                .frame(width: 46, height: 46)

            // Önce servis logosu varsa onu göster
            if let service = sub.service {
                Image(service.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 46, height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                // Yoksa eski SF Symbol ikonuna düş
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .semibold))
            }
        }
    }

    private var iconName: String {
        let n = sub.name.lowercased()
        if n.contains("youtube") { return "play.rectangle.fill" }
        if n.contains("netflix") { return "film" }
        if n.contains("spotify") { return "music.note" }
        if n.contains("icloud") { return "icloud.fill" }
        if n.contains("prime") || n.contains("amazon") { return "shippingbox.fill" }
        if n.contains("chatgpt") { return "bolt.fill" }
        return "creditcard"
    }

    // MARK: - Status badge

    private var statusBadge: some View {
        let effective = sub.overrideDecision ?? sub.aiDecision

        let (key, color): (LocalizedStringKey, Color) = {
            switch effective {
            case .keep:
                return ("status.active", .green)
            case .cancel:
                return ("status.cancelled", .red)
            case .review:
                return ("status.review", .orange)
            }
        }()

        return HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(key, bundle: .main)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }

    // MARK: - Text helpers

    private var cycleDisplayKey: LocalizedStringKey {
        switch sub.cycle {
        case .weekly:  return "cycle.weekly"
        case .monthly: return "cycle.monthly"
        case .yearly:  return "cycle.yearly"
        }
    }

    private var currencyCode: String {
        let code = sub.currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if !code.isEmpty { return code }
        return Locale.current.currency?.identifier ?? "TRY"
    }

    private var pricePerCycleText: some View {
        let formatted = sub.price.formatted(.currency(code: currencyCode))
        return HStack(spacing: 0) {
            Text(formatted)
            Text(" / ")
            Text(cycleDisplayKey, bundle: .main)
        }
    }
}
