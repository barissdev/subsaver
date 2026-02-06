import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme

    /// Ayarlardan seçilen varsayılan para birimi
    private var currencyCode: String {
        store.defaultCurrency
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        summaryCard
                        yearCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: 0)
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: colorScheme == .dark
            ? [Color(red: 0.05, green: 0.10, blue: 0.20),
               Color(red: 0.01, green: 0.04, blue: 0.10)]
            : [Color(red: 0.94, green: 0.97, blue: 1.0),
               Color(red: 0.88, green: 0.93, blue: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("statistics.title", bundle: .main)
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            Spacer()
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        // Burada FONKSİYONU çağırıyoruz:
        let monthly = store.monthlyTotal(in: currencyCode)
        let yearly  = store.yearlyTotal(in: currencyCode)

        // Potansiyel tasarruf zaten defaultCurrency cinsinden
        let potentialMonthly = store.potentialMonthlySavingsInDefaultCurrency
        let potentialYearly  = potentialMonthly * 12.0

        return VStack(alignment: .leading, spacing: 16) {
            Text("statistics.summary", bundle: .main)
                .font(.headline)
                .foregroundColor(.primary)

            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("statistics.monthlyTotal", bundle: .main)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(monthly, format: .currency(code: currencyCode))
                        .font(.title2.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("statistics.yearlyTotal", bundle: .main)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(yearly, format: .currency(code: currencyCode))
                        .font(.headline.bold())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                }
            }

            Divider().overlay(Color.primary.opacity(0.08))

            VStack(alignment: .leading, spacing: 4) {
                Text("statistics.potentialSavings", bundle: .main)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(potentialMonthly, format: .currency(code: currencyCode))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)

                Text("statistics.potentialYearly", bundle: .main) +
                Text(potentialYearly, format: .currency(code: currencyCode))
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .glassCard()
    }

    // MARK: - Year Card

    private var yearCard: some View {
        let yearly = store.yearlyTotal(in: currencyCode)
        let paidSoFar = yearly   // istersen burada gerçek “bugüne kadar ödenen”i hesaplayabilirsin
        let remaining = max(yearly - paidSoFar, 0)

        return VStack(alignment: .leading, spacing: 14) {
            Text("statistics.thisYear", bundle: .main)
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("statistics.plannedYearly", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(yearly, format: .currency(code: currencyCode))
                        .font(.subheadline.weight(.semibold))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("statistics.remainingPayment", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(remaining, format: .currency(code: currencyCode))
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
        .glassCard()
    }
}
