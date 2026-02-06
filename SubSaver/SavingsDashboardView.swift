import SwiftUI

struct SavingsDashboardView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme

    private var currencyCode: String {
        store.defaultCurrency.uppercased()
    }

    // Sadece iptal (Cancel) olarak işaretlenen abonelikler
    private var cancelledSubs: [Subscription] {
        store.items.filter { ($0.overrideDecision ?? $0.aiDecision) == .cancel }
    }

    // Aylık ve yıllık potansiyel tasarruflar (varsayılan para biriminde)
    private var monthlySavings: Double {
        cancelledSubs.reduce(0) { $0 + monthlyCost(for: $1) }
    }

    private var yearlySavings: Double {
        monthlySavings * 12.0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    VStack(spacing: 20) {
                        header

                        summaryCard

                        if cancelledSubs.isEmpty == false {
                            listCard
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: colorScheme == .dark
            ? [Color(red: 0.06, green: 0.10, blue: 0.24),
               Color(red: 0.01, green: 0.04, blue: 0.13)]
            : [Color(red: 0.94, green: 0.97, blue: 1.0),
               Color(red: 0.87, green: 0.93, blue: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Tasarruf Detayı")
                .font(.largeTitle.bold())
                .foregroundColor(.primary)

            Spacer()
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Potansiyel Tasarruf")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aylık")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(monthlySavings, format: .currency(code: currencyCode))
                        .font(.title2.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Yıllık")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(yearlySavings, format: .currency(code: currencyCode))
                        .font(.title3.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
            }

            Divider().overlay(Color.primary.opacity(0.08))

            Text("Kapalı olarak işaretlenen abonelikleri iptal edersen bu kadar tasarruf edebilirsin.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .savingsCard()
    }

    // MARK: - List

    private var listCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Aboneliklere Göre Dağılım")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            ForEach(cancelledSubs) { sub in
                HStack(spacing: 12) {
                    // Logo veya ikon
                    if let service = sub.service {
                        Image(service.assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        Image(systemName: "creditcard")
                            .font(.system(size: 18, weight: .semibold))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(sub.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Text("Aylık \(monthlyCost(for: sub), format: .currency(code: currencyCode))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(percentage(of: sub), format: .percent.precision(.fractionLength(0)))")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.primary.opacity(0.06))
                        )
                }
                .padding(.vertical, 4)

                if sub.id != cancelledSubs.last?.id {
                    Divider().overlay(Color.primary.opacity(0.06))
                }
            }
        }
        .savingsCard()
    }

    // Bir aboneliğin toplam tasarruf içindeki yüzdesi
    private func percentage(of sub: Subscription) -> Double {
        let m = monthlyCost(for: sub)
        guard monthlySavings > 0 else { return 0 }
        return m / monthlySavings
    }

    // MARK: - Cost helpers (varsayılan para biriminde)

    private func monthlyCost(for sub: Subscription) -> Double {
        let monthlyOriginal: Double
        switch sub.cycle {
        case .weekly:
            monthlyOriginal = sub.price * (52.0 / 12.0)
        case .monthly:
            monthlyOriginal = sub.price
        case .yearly:
            monthlyOriginal = sub.price / 12.0
        }

        return store.convert(
            amount: monthlyOriginal,
            from: sub.currencyCode,
            to: store.defaultCurrency
        )
    }
}

// MARK: - Kart stili (glassCard’dan bağımsız)

private extension View {
    func savingsCard() -> some View {
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
            .shadow(color: .black.opacity(0.16), radius: 12, x: 0, y: 8)
    }
}
