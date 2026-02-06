import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var languageManager: LanguageManager

    @State private var showLanguageSheet = false
    @AppStorage("themeMode") private var themeMode: String = "system"

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                background

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        currencySection
                        themeSection
                        notificationsSection
                        languageSection
                        rateUsSection
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
            ? [
                Color(red: 0.07, green: 0.11, blue: 0.22),
                Color(red: 0.01, green: 0.05, blue: 0.12)
            ]
            : [
                Color(red: 0.93, green: 0.96, blue: 1.0),
                Color(red: 0.86, green: 0.92, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("settings.title", bundle: .main)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("settings.subtitle", bundle: .main)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 16)
    }

    // MARK: - Currency

    private let supportedCurrencies = ["USD", "EUR", "TRY", "GBP", "CHF", "JPY"]

    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("settings.currency.title", bundle: .main)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            HStack {
                Text("settings.currency.description", bundle: .main)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(store.defaultCurrency)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Picker(selection: Binding(
                get: { store.defaultCurrency },
                set: { newValue in
                    store.defaultCurrency = newValue    // didSet içinde kurlar yenileniyor
                }
            )) {
                ForEach(supportedCurrencies, id: \.self) { code in
                    Text(code)
                        .tag(code)
                }
            } label: {
                Text("settings.currency.title", bundle: .main)
            }
            .pickerStyle(.menu)

            Text("settings.currency.help", bundle: .main)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .glassCard()
    }

    // MARK: - Tema

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("settings.theme.title", bundle: .main)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            Picker(selection: $themeMode) {
                Text("settings.theme.system", bundle: .main).tag("system")
                Text("settings.theme.light", bundle: .main).tag("light")
                Text("settings.theme.dark", bundle: .main).tag("dark")
            } label: {
                Text("settings.theme.title", bundle: .main)
            }
            .pickerStyle(.segmented)
        }
        .glassCard()
    }

    // MARK: - Bildirimler

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle(isOn: $store.notificationsEnabled) {
                Text("settings.notifications.title", bundle: .main)
                    .font(.subheadline)
            }
            .onChange(of: store.notificationsEnabled, initial: false) { oldValue, newValue in
                // Değer gerçekten değiştiyse çalışsın
                guard oldValue != newValue else { return }

                if newValue {
                    // Bildirim izni iste
                    Task {
                        _ = await NotificationScheduler.ensureAuthorization()
                    }
                } else {
                    // Tüm bildirimleri iptal et
                    Task {
                        await NotificationScheduler.cancelAll()
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("settings.notifications.days", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(String(format: NSLocalizedString("settings.notifications.daysBefore", bundle: .main, comment: ""), store.reminderDaysBefore))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Stepper(
                    "",
                    value: Binding(
                        get: { store.reminderDaysBefore },
                        set: { newValue in
                            store.reminderDaysBefore = newValue
                            // async fonksiyonu yine Task içinde çağırıyoruz
                            Task {
                                await store.rescheduleAllReminders()
                            }
                        }
                    ),
                    in: 0...30
                )
                .labelsHidden()
            }
        }
        .glassCard()
    }

    // MARK: - Language

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "globe")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("settings.language.title", bundle: .main)
                        .font(.subheadline.weight(.semibold))
                    Text("settings.language.description", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showLanguageSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text(languageManager.getLanguageName(languageManager.currentLanguage))
                            .font(.footnote.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
            }
        }
        .glassCard()
        .sheet(isPresented: $showLanguageSheet) {
            LanguageSelectionView()
                .environmentObject(languageManager)
        }
    }

    // MARK: - Rate us

    private var rateUsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.yellow.opacity(0.18))
                        .frame(width: 40, height: 40)

                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.yellow)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("settings.rateUs.title", bundle: .main)
                        .font(.subheadline.weight(.semibold))
                    Text("settings.rateUs.description", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 6) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }

                Spacer()

                Button {
                    if let url = URL(string: "https://apps.apple.com") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("settings.rateUs.button", bundle: .main)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThickMaterial)
                        .clipShape(Capsule())
                }
            }
        }
        .glassCard()
    }
}

// MARK: - Basit dil seçimi sheet'i

struct LanguageSelectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        
                        languageOptions
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("settings.language.title", bundle: .main)
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var background: some View {
        LinearGradient(
            colors: colorScheme == .dark
            ? [
                Color(red: 0.07, green: 0.11, blue: 0.22),
                Color(red: 0.01, green: 0.05, blue: 0.12)
            ]
            : [
                Color(red: 0.93, green: 0.96, blue: 1.0),
                Color(red: 0.86, green: 0.92, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("settings.language.selection", bundle: .main)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("settings.language.selectPrompt", bundle: .main)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var languageOptions: some View {
        VStack(spacing: 12) {
            ForEach(languageManager.availableLanguages, id: \.code) { language in
                languageOptionCard(language: language)
            }
        }
    }
    
    private func languageOptionCard(language: (code: String, name: String)) -> some View {
        Button {
            languageManager.setLanguage(language.code)
            dismiss()
        } label: {
            HStack(spacing: 16) {
                // Dil ikonu
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconForLanguage(language.code))
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                // Dil bilgisi
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    if language.code == "system" {
                        Text("settings.language.systemDescription", bundle: .main)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(language.code == "tr" ? "Turkish" : "English")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Seçili işareti
                if languageManager.currentLanguage == language.code {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary.opacity(0.3))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        languageManager.currentLanguage == language.code
                        ? Color.blue.opacity(0.5)
                        : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func iconForLanguage(_ code: String) -> String {
        switch code {
        case "system":
            return "globe"
        case "tr":
            return "character.book.closed"
        case "en":
            return "character.book.closed"
        default:
            return "globe"
        }
    }
}
