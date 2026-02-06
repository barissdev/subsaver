import SwiftUI

@main
struct SubSaverApp: App {
    @StateObject private var store = SubscriptionStore()
    @StateObject private var languageManager = LanguageManager.shared

    // Onboarding
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // Tema (SettingsView ile aynı key)
    @AppStorage("themeMode") private var themeMode: String = "system"

    private var resolvedColorScheme: ColorScheme? {
        switch themeMode {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil        // Sistem varsayılanı
        }
    }
    
    /// Seçilen dile göre Locale döndürür
    private var currentLocale: Locale {
        switch languageManager.selectedLanguageCode {
        case "tr":
            return Locale(identifier: "tr")
        case "en":
            return Locale(identifier: "en")
        default:
            return Locale.current
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    RootTabView()
                } else {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                }
            }
            .environmentObject(store)
            .environmentObject(languageManager)
            .preferredColorScheme(resolvedColorScheme)
            // Dil değiştiğinde tüm view hiyerarşisini yeniden oluştur
            .id(languageManager.refreshTrigger)
            .environment(\.locale, currentLocale)
        }
    }
}

