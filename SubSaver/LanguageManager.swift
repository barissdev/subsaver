import Foundation
import SwiftUI
import ObjectiveC

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    /// SwiftUI view'larını yeniden render etmek için kullanılan tetikleyici
    /// Bu değer her dil değişikliğinde değişir ve .id() modifier ile kullanılır
    @Published var refreshTrigger: UUID = UUID()
    
    @AppStorage("selectedLanguage") var selectedLanguageCode: String = "system" {
        didSet {
            applyLanguage(selectedLanguageCode)
        }
    }
    
    var currentLanguage: String {
        selectedLanguageCode
    }
    
    init() {
        // Uygulama başlangıcında dil ayarını uygula
        applyLanguage(selectedLanguageCode)
    }
    
    func setLanguage(_ code: String) {
        if selectedLanguageCode != code {
            selectedLanguageCode = code
        } else {
            // Aynı dili seçilmişse bile uygula (yeniden başlatma için)
            applyLanguage(code)
        }
        // SwiftUI view'larını yeniden render etmek için tetikleyiciyi güncelle
        refreshTrigger = UUID()
    }
    
    private func applyLanguage(_ code: String) {
        Bundle.setLanguage(code == "system" ? nil : code)
    }
    
    func getLanguageName(_ code: String) -> String {
        switch code {
        case "tr":
            return "Türkçe"
        case "en":
            return "English"
        case "system":
            return "Sistem dili"
        default:
            return code
        }
    }
    
    var availableLanguages: [(code: String, name: String)] {
        [
            ("system", "Sistem dili (önerilen)"),
            ("tr", "Türkçe"),
            ("en", "English")
        ]
    }
}

// Bundle extension to support custom language
private var currentLanguage: String?
private var cachedLanguageBundle: Bundle?
private let originalMainBundlePath = Bundle.main.bundlePath

extension Bundle {
    static var selectedLanguage: String? {
        get {
            return currentLanguage
        }
        set {
            currentLanguage = newValue
            // Cache'i temizle
            cachedLanguageBundle = nil
        }
    }
    
    /// Seçilen dile göre lokalize edilmiş bundle döndürür
    static var localized: Bundle {
        // Cache kontrolü
        if let cached = cachedLanguageBundle {
            return cached
        }
        
        let languageCode = Bundle.selectedLanguage ?? Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        
        let lprojPath = (originalMainBundlePath as NSString).appendingPathComponent("\(languageCode).lproj")
        
        if FileManager.default.fileExists(atPath: lprojPath),
           let bundle = Bundle(path: lprojPath) {
            cachedLanguageBundle = bundle
            return bundle
        }
        
        // Fallback to main bundle
        cachedLanguageBundle = .main
        return .main
    }
    
    static func setLanguage(_ language: String?) {
        let code = language == "system" ? nil : language
        Bundle.selectedLanguage = code
        
        // Cache'i temizle - yeni dil için bundle yeniden oluşturulacak
        cachedLanguageBundle = nil
        
        // Bundle.main'i override et - SwiftUI Text views için
        // object_setClass ile runtime'da class'ı değiştiriyoruz
        // Bu, Bundle.main'in localizedString metodunu override eder
        object_setClass(Bundle.main, AnyLanguageBundle.self)
    }
}

// Bundle.main'in localizedString metodunu override eden custom class
private class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // Seçilen dili al, yoksa sistem dilini kullan
        let languageCode: String
        if let selected = Bundle.selectedLanguage {
            languageCode = selected
        } else {
            // Sistem dili kullanılıyor
            languageCode = Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        }
        
        // Orijinal main bundle path'ini kullanarak lproj dizinini bul
        let lprojPath = (originalMainBundlePath as NSString).appendingPathComponent("\(languageCode).lproj")
        
        // Eğer lproj dizini varsa, o bundle'dan lokalize edilmiş string'i al
        if FileManager.default.fileExists(atPath: lprojPath),
           let languageBundle = Bundle(path: lprojPath) {
            let localized = languageBundle.localizedString(forKey: key, value: value, table: tableName)
            return localized
        }
        
        // Fallback: Orijinal Bundle implementasyonunu kullan
        // super çağrısı, Bundle sınıfının orijinal localizedString metodunu çağırır
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

