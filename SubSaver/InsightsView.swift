import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme

    /// SettingsView ile aynı key'i kullan - store üzerinden
    private var targetCurrency: String {
        store.defaultCurrency
    }

    // MARK: - Para biriminde toplamlar

    private var monthlyBaseTotal: Double {
        store.items.reduce(0) { partial, sub in
            partial + monthlyCostBase(for: sub)
        }
    }

    private var yearlyBaseTotal: Double {
        monthlyBaseTotal * 12
    }

    /// Kapalı / iptal aboneliklerden yıllık potansiyel tasarruf (base para biriminde)
    private var potentialYearlySavingBase: Double {
        store.items
            .filter { ($0.overrideDecision ?? $0.aiDecision) == .cancel }
            .reduce(0) { partial, sub in
                partial + yearlyCostBase(for: sub)
            }
    }

    // MARK: - Maliyet hesaplama

    /// Tek aboneliğin hedef para biriminde AYLIK maliyeti
    private func monthlyCostBase(for sub: Subscription) -> Double {
        // Önce aboneliği aylık bazda hesapla
        let monthlyOriginal: Double
        switch sub.cycle {
        case .weekly:
            monthlyOriginal = sub.price * (52.0 / 12.0)
        case .monthly:
            monthlyOriginal = sub.price
        case .yearly:
            monthlyOriginal = sub.price / 12.0
        }
        
        // Sonra hedef para birimine çevir
        return store.convert(amount: monthlyOriginal, from: sub.currencyCode, to: targetCurrency)
    }

    /// Tek aboneliğin hedef para biriminde YILLIK maliyeti
    private func yearlyCostBase(for sub: Subscription) -> Double {
        return monthlyCostBase(for: sub) * 12.0
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // HomeView ile aynı hissiyat
            LinearGradient(
                colors: colorScheme == .dark
                ? [Color(red: 0.06, green: 0.10, blue: 0.22),
                   Color(red: 0.02, green: 0.05, blue: 0.14)]
                : [Color(red: 0.94, green: 0.97, blue: 1.0),
                   Color(red: 0.88, green: 0.93, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header

                    summaryCard
                    yearOverviewCard
                    breakdownCard
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 0)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("İstatistik")
                    .font(.largeTitle.weight(.bold))
                Text("Harcamalarını ve tasarruflarını bir bakışta gör.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Cards

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Özet")
                .font(.subheadline.weight(.semibold))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Aylık Toplam")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(monthlyBaseTotal,
                         format: .currency(code: targetCurrency))
                    .font(.title3.weight(.bold))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Yıllık Toplam")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(yearlyBaseTotal,
                         format: .currency(code: targetCurrency))
                    .font(.title3.weight(.bold))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Potansiyel Tasarruf (yıllık)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(potentialYearlySavingBase,
                     format: .currency(code: targetCurrency))
                .font(.headline.weight(.semibold))
                .foregroundColor(.green)
            }

            Text("Tüm toplamlar \(targetCurrency) cinsinden, canlı döviz kurları ile hesaplanır.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .glassCard()
    }

    private var yearOverviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bu Yıl")
                .font(.subheadline.weight(.semibold))

            let paidSoFar = paidSoFarBase()
            let planned   = yearlyBaseTotal
            let remaining = max(planned - paidSoFar, 0)

            row("Planlanan yıllık harcama",
                value: planned)

            row("Bugüne kadar tahmini ödeme",
                value: paidSoFar)

            row("Kalan tahmini ödeme",
                value: remaining)

            row("Kapalı aboneliklerden potansiyel tasarruf (yıllık)",
                value: potentialYearlySavingBase)
        }
        .glassCard()
    }

    private func row(_ title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(.caption2)
            Spacer()
            Text(value, format: .currency(code: targetCurrency))
                .font(.caption.weight(.semibold))
        }
    }

    private func paidSoFarBase() -> Double {
        let cal = Calendar.current
        let now = Date()
        guard
            let startOfYear = cal.date(from: cal.dateComponents([.year], from: now)),
            let endOfYear = cal.date(byAdding: DateComponents(year: 1, day: -1),
                                     to: startOfYear)
        else { return yearlyBaseTotal }

        let totalInterval = endOfYear.timeIntervalSince(startOfYear)
        let passed        = now.timeIntervalSince(startOfYear)
        let ratio         = max(0, min(1, passed / totalInterval))

        return yearlyBaseTotal * ratio
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Döngü Dağılımı")
                .font(.subheadline.weight(.semibold))

            let weekly  = store.items.filter { $0.cycle == .weekly }.count
            let monthly = store.items.filter { $0.cycle == .monthly }.count
            let yearly  = store.items.filter { $0.cycle == .yearly }.count
            let total   = max(store.items.count, 1)

            breakdownRow("Haftalık", count: weekly, total: total)
            breakdownRow("Aylık",   count: monthly, total: total)
            breakdownRow("Yıllık",  count: yearly, total: total)
        }
        .glassCard()
    }

    private func breakdownRow(_ title: String, count: Int, total: Int) -> some View {
        let ratio = CGFloat(count) / CGFloat(total)

        return HStack {
            Text(title)
                .font(.caption2)

            Spacer()

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 120, height: 6)

                Capsule()
                    .fill(Color.blue)
                    .frame(width: 120 * ratio, height: 6)
            }

            Text("\(count)")
                .font(.caption2.weight(.semibold))
        }
    }
}
