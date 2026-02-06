import SwiftUI

// Tüm projede kullanacağımız ortak glassCard görünümü
extension View {
    func glassCard() -> some View {
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
            .shadow(color: .black.opacity(0.20), radius: 12, x: 0, y: 10)
    }
}
