import SwiftUI

struct ServiceItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String  // SF Symbol
    let accent: Color
}

enum ServiceCatalog {
    static let popular: [ServiceItem] = [
        .init(name: "Netflix", icon: "film", accent: .red),
        .init(name: "Spotify", icon: "music.note", accent: .green),
        .init(name: "YouTube Premium", icon: "play.rectangle.fill", accent: .red),
        .init(name: "Apple iCloud+", icon: "icloud.fill", accent: .blue),
        .init(name: "Disney+", icon: "sparkles.tv", accent: .blue),
        .init(name: "Amazon Prime", icon: "shippingbox.fill", accent: .orange),
        .init(name: "ChatGPT Plus", icon: "bolt.fill", accent: .mint),
        .init(name: "Notion", icon: "square.grid.2x2.fill", accent: .gray)
    ]
}

