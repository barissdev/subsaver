import SwiftUI

/// Abonelik logoları için küçük, reusable component.
/// `service` şimdilik opsiyonel, sadece ileride istersen kullanırsın.
/// Şu an tamamen `name` üzerinden ikon seçiyor.
struct SubscriptionLogoView: View {
    let service: SubscriptionService?
    let name: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)

            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
        }
        .frame(width: 32, height: 32)
    }

    // İleride service'e göre de ikon/kutu rengi verebilirsin.
    // Şimdilik sadece isme göre SF Symbol seçiyoruz.
    private var iconName: String {
        let lower = name.lowercased()

        if lower.contains("netflix")     { return "n.square.fill" }     // yoksa "film.fill"
        if lower.contains("youtube")    { return "play.rectangle.fill" }
        if lower.contains("spotify")    { return "music.note" }
        if lower.contains("icloud")     { return "icloud.fill" }
        if lower.contains("prime") ||
           lower.contains("amazon")     { return "shippingbox.fill" }
        if lower.contains("disney")     { return "sparkles.tv.fill" }
        if lower.contains("apple") &&
           lower.contains("music")      { return "music.note.list" }
        if lower.contains("chatgpt") ||
           lower.contains("openai")     { return "bolt.fill" }

        // Varsayılan ikon
        return "creditcard.fill"
    }
}
