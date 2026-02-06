import Foundation

/// Global abonelik servisleri + logoları
enum SubscriptionService: String, CaseIterable, Identifiable, Codable, Hashable {
    // Video
    case netflix
    case youtubePremium
    case disneyPlus
    case amazonPrimeVideo
    case appleTVPlus
    case max        // HBO Max / Max
    case hulu
    case paramountPlus
    case peacock
    case crunchyroll

    // Müzik
    case spotify
    case appleMusic
    case youtubeMusic
    case tidal
    case deezer

    // Oyun
    case xboxGamePass
    case playStationPlus
    case nintendoOnline
    case eaPlay

    // Bulut / üretkenlik
    case icloudPlus
    case googleOne
    case dropbox
    case onedrive
    case microsoft365
    case adobeCC
    case notion
    case evernote
    case zoomPro
    case canvaPro

    // AI / araçlar
    case chatgptPlus
    case claudePro
    case copilotPro
    case midjourney

    // Diğer popüler
    case spotifyFamily
    case amazonMusic
    case kindleUnlimited

    var id: String { rawValue }

    /// Listelerde gösterilecek isim
    var displayName: String {
        switch self {
        // Video
        case .netflix:           return "Netflix"
        case .youtubePremium:    return "YouTube Premium"
        case .disneyPlus:        return "Disney+"
        case .amazonPrimeVideo:  return "Amazon Prime Video"
        case .appleTVPlus:       return "Apple TV+"
        case .max:               return "Max"
        case .hulu:              return "Hulu"
        case .paramountPlus:     return "Paramount+"
        case .peacock:           return "Peacock"
        case .crunchyroll:       return "Crunchyroll"

        // Müzik
        case .spotify:           return "Spotify"
        case .appleMusic:        return "Apple Music"
        case .youtubeMusic:      return "YouTube Music"
        case .tidal:             return "TIDAL"
        case .deezer:            return "Deezer"

        // Oyun
        case .xboxGamePass:      return "Xbox Game Pass"
        case .playStationPlus:   return "PlayStation Plus"
        case .nintendoOnline:    return "Nintendo Switch Online"
        case .eaPlay:            return "EA Play"

        // Bulut / üretkenlik
        case .icloudPlus:        return "iCloud+"
        case .googleOne:         return "Google One"
        case .dropbox:           return "Dropbox"
        case .onedrive:          return "OneDrive"
        case .microsoft365:      return "Microsoft 365"
        case .adobeCC:           return "Adobe Creative Cloud"
        case .notion:            return "Notion"
        case .evernote:          return "Evernote"
        case .zoomPro:           return "Zoom Pro"
        case .canvaPro:          return "Canva Pro"

        // AI
        case .chatgptPlus:       return "ChatGPT Plus"
        case .claudePro:         return "Claude Pro"
        case .copilotPro:        return "Copilot Pro"
        case .midjourney:        return "Midjourney"

        // Diğer
        case .spotifyFamily:     return "Spotify Family"
        case .amazonMusic:       return "Amazon Music"
        case .kindleUnlimited:   return "Kindle Unlimited"
        }
    }

    /// Asset Catalog’daki logo ismi
    /// Xcode > Assets.xcassets içine bu isimlerle görselleri ekle.
    var assetName: String {
        switch self {
        // Video
        case .netflix:           return "logo_netflix"
        case .youtubePremium:    return "logo_youtube_premium"
        case .disneyPlus:        return "logo_disney_plus"
        case .amazonPrimeVideo:  return "logo_amazon_prime_video"
        case .appleTVPlus:       return "logo_apple_tv_plus"
        case .max:               return "logo_max"
        case .hulu:              return "logo_hulu"
        case .paramountPlus:     return "logo_paramount_plus"
        case .peacock:           return "logo_peacock"
        case .crunchyroll:       return "logo_crunchyroll"

        // Müzik
        case .spotify:           return "logo_spotify"
        case .appleMusic:        return "logo_apple_music"
        case .youtubeMusic:      return "logo_youtube_music"
        case .tidal:             return "logo_tidal"
        case .deezer:            return "logo_deezer"

        // Oyun
        case .xboxGamePass:      return "logo_xbox_game_pass"
        case .playStationPlus:   return "logo_playstation_plus"
        case .nintendoOnline:    return "logo_nintendo_online"
        case .eaPlay:            return "logo_ea_play"

        // Bulut / üretkenlik
        case .icloudPlus:        return "logo_icloud_plus"
        case .googleOne:         return "logo_google_one"
        case .dropbox:           return "logo_dropbox"
        case .onedrive:          return "logo_onedrive"
        case .microsoft365:      return "logo_microsoft_365"
        case .adobeCC:           return "logo_adobe_cc"
        case .notion:            return "logo_notion"
        case .evernote:          return "logo_evernote"
        case .zoomPro:           return "logo_zoom_pro"
        case .canvaPro:          return "logo_canva_pro"

        // AI
        case .chatgptPlus:       return "logo_chatgpt_plus"
        case .claudePro:         return "logo_claude_pro"
        case .copilotPro:        return "logo_copilot_pro"
        case .midjourney:        return "logo_midjourney"

        // Diğer
        case .spotifyFamily:     return "logo_spotify_family"
        case .amazonMusic:       return "logo_amazon_music"
        case .kindleUnlimited:   return "logo_kindle_unlimited"
        }
    }
}

