import SwiftUI

struct ProView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var store: SubscriptionStore

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    VStack(spacing: 22) {
                        header
                        heroCard
                        featuresGrid
                        compareCard
                        faqSection
                        ctaSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("pro.hero.title", bundle: .main)
                            .font(.headline.weight(.semibold))
                    }
                }
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: colorScheme == .dark
            ? [Color(red: 0.03, green: 0.06, blue: 0.16),
               Color(red: 0.10, green: 0.05, blue: 0.25)]
            : [Color(red: 0.93, green: 0.96, blue: 1.0),
               Color(red: 0.94, green: 0.90, blue: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("pro.title", bundle: .main)
                .font(.title2.weight(.bold))

            Text("pro.subtitle", bundle: .main)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Hero card

    private var heroCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.9), Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)

                    Image(systemName: "sparkles")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                }

            VStack(alignment: .leading, spacing: 4) {
                    Text("pro.hero.title", bundle: .main)
                        .font(.headline.weight(.semibold))

                    Text("pro.hero.description", bundle: .main)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("₺29,99")
                    .font(.title2.weight(.bold))
                Text("pro.hero.monthly", bundle: .main)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("pro.hero.soon", bundle: .main)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .foregroundColor(.yellow)
                    .clipShape(Capsule())
            }

            HStack(spacing: 8) {
                Image(systemName: "faceid")
                Text("pro.hero.faceidNote", bundle: .main)
                Spacer(minLength: 0)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .glassCard()
    }

    // MARK: - Özellikler grid

    private var featuresGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("pro.features.title", bundle: .main)
                .font(.subheadline.weight(.semibold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                featureTile(
                    icon: "chart.line.uptrend.xyaxis",
                    titleKey: "pro.features.stats.title",
                    subtitleKey: "pro.features.stats.subtitle"
                )

                featureTile(
                    icon: "bell.badge.fill",
                    titleKey: "pro.features.alerts.title",
                    subtitleKey: "pro.features.alerts.subtitle"
                )

                featureTile(
                    icon: "lock.shield.fill",
                    titleKey: "pro.features.faceid.title",
                    subtitleKey: "pro.features.faceid.subtitle"
                )

                featureTile(
                    icon: "sparkles",
                    titleKey: "pro.features.badges.title",
                    subtitleKey: "pro.features.badges.subtitle"
                )
            }
        }
        .glassCard()
    }

    private func featureTile(icon: String, titleKey: LocalizedStringKey, subtitleKey: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentColor)
            }

            Text(titleKey, bundle: .main)
                .font(.subheadline.weight(.semibold))

            Text(subtitleKey, bundle: .main)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.7))
        )
    }

    // MARK: - Karşılaştırma kartı

    private var compareCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("pro.compare.title", bundle: .main)
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 8) {
                compareRow(titleKey: "pro.compare.list", free: true, pro: true)
                compareRow(titleKey: "pro.compare.reminders", free: true, pro: true)
                compareRow(titleKey: "pro.compare.currency", free: true, pro: true)
                Divider().overlay(Color.primary.opacity(0.08))
                compareRow(titleKey: "pro.compare.advancedStats", free: false, pro: true)
                compareRow(titleKey: "pro.compare.faceid", free: false, pro: true)
                compareRow(titleKey: "pro.compare.themes", free: false, pro: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.9))
            )
        }
        .glassCard()
    }

    private func compareRow(titleKey: LocalizedStringKey, free: Bool, pro: Bool) -> some View {
        HStack {
            Text(titleKey, bundle: .main)
                .font(.caption)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundColor(free ? .green : .secondary.opacity(0.6))
                Text("pro.compare.free", bundle: .main)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80, alignment: .center)

            HStack(spacing: 4) {
                Image(systemName: pro ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundColor(pro ? .green : .secondary.opacity(0.6))
                Text("pro.compare.pro", bundle: .main)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60, alignment: .center)
        }
    }

    // MARK: - FAQ

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("pro.faq.title", bundle: .main)
                .font(.subheadline.weight(.semibold))

            faqRow(
                titleKey: "pro.faq.soon.q",
                bodyKey: "pro.faq.soon.a"
            )

            faqRow(
                titleKey: "pro.faq.data.q",
                bodyKey: "pro.faq.data.a"
            )

            faqRow(
                titleKey: "pro.faq.cancel.q",
                bodyKey: "pro.faq.cancel.a"
            )
        }
        .glassCard()
    }

    private func faqRow(titleKey: LocalizedStringKey, bodyKey: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titleKey, bundle: .main)
                .font(.caption.weight(.semibold))
            Text(bodyKey, bundle: .main)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: 10) {
            Button {
                // TODO: Buraya IAP entegrasyonu geldiğinde satın alma aksiyonu
            } label: {
                Text("pro.cta.notify", bundle: .main)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
            }

            Button {
                dismiss()
            } label: {
                Text("pro.cta.continue", bundle: .main)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                    )
            }
            .foregroundColor(.primary.opacity(0.9))
        }
    }
}
