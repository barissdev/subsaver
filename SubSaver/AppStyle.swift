import SwiftUI

/// Uygulamanın ortak arka planı – HomeView ile aynı gradient.
struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                ? [Color(red: 0.07, green: 0.12, blue: 0.25),
                   Color(red: 0.01, green: 0.06, blue: 0.15)]
                : [Color(red: 0.92, green: 0.96, blue: 1.0),
                   Color(red: 0.86, green: 0.92, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            AngularGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(colorScheme == .dark ? 0.55 : 0.30),
                    Color.purple.opacity(colorScheme == .dark ? 0.65 : 0.35),
                    Color.cyan.opacity(colorScheme == .dark ? 0.50 : 0.25),
                    Color.blue.opacity(colorScheme == .dark ? 0.55 : 0.30)
                ]),
                center: .center
            )
            .scaleEffect(1.8)
            .blur(radius: 120)
            .opacity(0.55)
            .ignoresSafeArea()
        }
    }
}

/// Home'daki kart stili ile aynı cam görünümlü kart.
extension View {
    func appGlassCard() -> some View {
        self
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 14)
    }

    /// Alt tab bar ile çakışmaması için her ekrana aynı alt boşluk.
    func appTabSafeInset() -> some View {
        self.safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 76)
        }
    }
}

/// Bölüm başlıkları için ortak yapı.
struct AppSectionHeader: View {
    let title: String
    let trailing: String?

    init(_ title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
