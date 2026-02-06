import SwiftUI

struct NotificationsListView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private var enabledSubscriptions: [Subscription] {
        store.items.filter { $0.notifyEnabled && store.notificationsEnabled }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                
                if enabledSubscriptions.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            headerCard
                            
                            ForEach(enabledSubscriptions) { sub in
                                notificationCard(for: sub)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("notifications.title", bundle: .main)
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("notifications.close", bundle: .main)
                    }
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var background: some View {
        LinearGradient(
            colors: colorScheme == .dark
            ? [
                Color(red: 0.07, green: 0.12, blue: 0.25),
                Color(red: 0.01, green: 0.06, blue: 0.15)
              ]
            : [
                Color(red: 0.92, green: 0.96, blue: 1.0),
                Color(red: 0.86, green: 0.92, blue: 1.0)
              ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.secondary)
            
            Text("notifications.empty", bundle: .main)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("notifications.emptyDescription", bundle: .main)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("notifications.enabledSubscriptions", bundle: .main)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(String(format: NSLocalizedString("notifications.activeCount", bundle: .main, comment: ""), enabledSubscriptions.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
                .overlay(Color.primary.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("notifications.defaultReminder", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(String(format: NSLocalizedString("notifications.daysBeforeShort", bundle: .main, comment: ""), store.reminderDaysBefore))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Notification Card
    
    private func notificationCard(for sub: Subscription) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Logo veya ikon
                if let service = sub.service {
                    Image(service.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "creditcard")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemBackground))
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sub.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(sub.renewalDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            
            Divider()
                .overlay(Color.primary.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("notifications.reminder", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(String(format: NSLocalizedString("notifications.daysBeforeShort", bundle: .main, comment: ""), sub.notifyDaysBefore))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Hatırlatma tarihini hesapla
                if let reminderDate = Calendar.current.date(
                    byAdding: .day,
                    value: -sub.notifyDaysBefore,
                    to: sub.renewalDate
                ) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("notifications.date", bundle: .main)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(reminderDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

