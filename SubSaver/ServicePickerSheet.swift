import SwiftUI

enum ServiceCategory: String, CaseIterable {
    case video = "category.video"
    case music = "category.music"
    case gaming = "category.gaming"
    case cloud = "category.cloud"
    case ai = "category.ai"
    case other = "category.other"
    
    var icon: String {
        switch self {
        case .video: return "play.tv.fill"
        case .music: return "music.note"
        case .gaming: return "gamecontroller.fill"
        case .cloud: return "icloud.fill"
        case .ai: return "sparkles"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var services: [SubscriptionService] {
        switch self {
        case .video:
            return [.netflix, .youtubePremium, .disneyPlus, .amazonPrimeVideo, .appleTVPlus, .max, .hulu, .paramountPlus, .peacock, .crunchyroll]
        case .music:
            return [.spotify, .appleMusic, .youtubeMusic, .tidal, .deezer, .spotifyFamily, .amazonMusic]
        case .gaming:
            return [.xboxGamePass, .playStationPlus, .nintendoOnline, .eaPlay]
        case .cloud:
            return [.icloudPlus, .googleOne, .dropbox, .onedrive, .microsoft365, .adobeCC, .notion, .evernote, .zoomPro, .canvaPro]
        case .ai:
            return [.chatgptPlus, .claudePro, .copilotPro, .midjourney]
        case .other:
            return [.kindleUnlimited]
        }
    }
}

struct ServicePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedService: SubscriptionService?
    @State private var searchText: String = ""
    @State private var selectedCategory: ServiceCategory? = .video
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Özel hizmet seçeneği
                        customServiceSection
                        
                        // Kategoriler (yatay scroll)
                        categoriesSection
                        
                        // Seçili kategorideki servisler
                        if let category = selectedCategory {
                            servicesSection(for: category)
                        }
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
                    Text("servicePicker.title", bundle: .main)
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("common.cancel", bundle: .main)
                    }
                }
            }
            .searchable(text: $searchText, prompt: Text("servicePicker.searchPrompt", bundle: .main))
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
    
    private var customServiceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("servicePicker.customService", bundle: .main)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            
            Button {
                selectedService = nil
                dismiss()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground).opacity(0.8))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "creditcard")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Text("servicePicker.custom", bundle: .main)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.systemBackground).opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("servicePicker.categories", bundle: .main)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ServiceCategory.allCases, id: \.self) { category in
                        categoryButton(category)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func categoryButton(_ category: ServiceCategory) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedCategory = category
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(selectedCategory == category ? .blue : .primary)
                
                Text(LocalizedStringKey(category.rawValue), bundle: .main)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(selectedCategory == category ? .blue : .primary)
            }
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selectedCategory == category 
                          ? Color.blue.opacity(0.15)
                          : Color(.secondarySystemBackground).opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(selectedCategory == category 
                                    ? Color.blue.opacity(0.3)
                                    : Color.clear,
                                    lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func servicesSection(for category: ServiceCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey(category.rawValue), bundle: .main)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                ForEach(filteredServices(for: category), id: \.self) { service in
                    serviceRow(service)
                }
            }
        }
    }
    
    private func serviceRow(_ service: SubscriptionService) -> some View {
        Button {
            selectedService = service
            dismiss()
        } label: {
            HStack(spacing: 16) {
                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground).opacity(0.8))
                        .frame(width: 60, height: 60)
                    
                    Image(service.assetName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                // İsim ve trademark uyarısı
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(trademarkText(for: service), bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Seçili işareti
                if selectedService == service {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(selectedService == service 
                          ? Color.blue.opacity(0.15)
                          : Color(.systemBackground).opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(selectedService == service
                                    ? Color.blue.opacity(0.3)
                                    : Color.primary.opacity(0.06),
                                    lineWidth: selectedService == service ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func trademarkText(for service: SubscriptionService) -> LocalizedStringKey {
        switch service {
        case .youtubePremium:
            return "servicePicker.trademark.youtube"
        case .amazonPrimeVideo, .amazonMusic, .kindleUnlimited:
            return "servicePicker.trademark.amazon"
        case .max:
            return "servicePicker.trademark.max"
        default:
            return "servicePicker.trademark.default"
        }
    }
    
    private func filteredServices(for category: ServiceCategory) -> [SubscriptionService] {
        let services = category.services
        
        if searchText.isEmpty {
            return services
        }
        
        let query = searchText.lowercased()
        return services.filter { service in
            service.displayName.lowercased().contains(query)
        }
    }
}

