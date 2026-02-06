import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: SubscriptionStore
    @Environment(\.colorScheme) private var colorScheme

    // Animasyon state'leri
    @State private var appearHeader = false
    @State private var appearSummary = false
    @State private var appearUpcoming = false
    @State private var appearList = false
    @State private var showPro = false

    // Detay sheet'i için
    @State private var editingSub: Subscription?
    // Abonelik ekleme sheet'i için
    @State private var showAddSubscription = false
    // Bildirimleri açık abonelikler sheet'i için
    @State private var showNotificationsList = false
    // Açık swipe satırı ID'si (scroll veya dış tıklamada kapatmak için)
    @State private var openSwipeRowId: UUID? = nil

    // Varsayılan gösterim para birimi (Settings’ten)
    private var currencyCode: String {
        store.defaultCurrency
    }

    var body: some View {
        NavigationStack {
            ZStack {
                animatedBackground
                    .onTapGesture {
                        // Arka plana tıklanınca açık satırı kapat
                        if openSwipeRowId != nil {
                            openSwipeRowId = nil
                        }
                    }

                ScrollView {
                    VStack(spacing: 22) {
                        summarySection
                            .opacity(appearSummary ? 1 : 0)
                            .offset(y: appearSummary ? 0 : 20)

                        if hasUpcoming {
                            upcomingSection
                                .opacity(appearUpcoming ? 1 : 0)
                                .offset(y: appearUpcoming ? 0 : 24)
                        }

                        subscriptionsSection
                            .opacity(appearList ? 1 : 0)
                            .offset(y: appearList ? 0 : 28)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .top) {
                    headerSection
                        .opacity(appearHeader ? 1 : 0)
                        .offset(y: appearHeader ? 0 : 16)
                        .padding(.horizontal, 18)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        .background(
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
                            .ignoresSafeArea(edges: .top)
                        )
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            // Dikey scroll algılandığında açık satırı kapat
                            let dy = abs(value.translation.height)
                            if dy > 20 && openSwipeRowId != nil {
                                openSwipeRowId = nil
                            }
                        }
                )
            }
            .navigationBarHidden(true)
            .sheet(item: $editingSub) { sub in
                SubscriptionDetailView(sub: sub)
            }
            .sheet(isPresented: $showAddSubscription) {
                AddSubscriptionView()
            }
            .sheet(isPresented: $showNotificationsList) {
                NotificationsListView()
            }
            .onAppear { startAnimations() }
        }
        .sheet(isPresented: $showPro) {
                    ProView()
                        .environmentObject(store)
                }
    }

    // MARK: - Arka Plan

    private var animatedBackground: some View {
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

    private var headerSection: some View {
        ZStack {
            HStack(spacing: 14) {
                Button {
                    showNotificationsList = true
                } label: {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(alignment: .topTrailing) {
                            if !notificationsEnabledSubscriptions.isEmpty {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                }

                Spacer(minLength: 0)

                Button {
                    showPro = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                        Text("Pro")
                            .font(.footnote.weight(.semibold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                }
            }

            VStack(spacing: 2) {
                Text("SubSaver")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("home.subtitle", bundle: .main)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Summary

    private var summarySection: some View {
        let monthly = store.totalMonthlyInDefaultCurrency
        let yearly  = store.totalYearlyInDefaultCurrency

        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("home.totalMonthly", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(monthly, format: .currency(code: currencyCode))
                        .font(.system(size: 30, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Image(systemName: "waveform.path.ecg")
                        Text("home.subscriptionsActive", bundle: .main)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 8) {
                    Text("home.totalYearly", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(yearly, format: .currency(code: currencyCode))
                        .font(.headline.weight(.semibold))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(.primary)

                    Capsule()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 80, height: 3)

                    Text("home.plannedSpending", bundle: .main)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                statChip(
                    key: "home.activeSubscriptions",
                    value: "\(activeSubscriptions.count)"
                )

                statChip(
                    key: "home.cancelCandidates",
                    value: "\(cancelCandidates.count)"
                )
            }
        }
        .glassCard()
    }

    private func statChip(key: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key, bundle: .main)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Upcoming Helpers (lokal, store extension yok)

    private var activeSubscriptions: [Subscription] {
        store.items.filter { ($0.overrideDecision ?? $0.aiDecision) == .keep }
    }

    private var cancelCandidates: [Subscription] {
        store.items.filter { ($0.overrideDecision ?? $0.aiDecision) == .cancel }
    }

    private var renewingToday: [Subscription] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return store.items.filter { cal.isDate($0.renewalDate, inSameDayAs: today) }
    }

    private var overdueRenewalsList: [Subscription] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return store.items
            .filter { $0.renewalDate < today }
            .sorted { $0.renewalDate < $1.renewalDate }
    }

    private func upcomingRenewals(within days: Int) -> [Subscription] {
        let now = Date()
        guard let target = Calendar.current.date(byAdding: .day, value: days, to: now) else {
            return []
        }

        return store.items
            .filter { sub in
                sub.renewalDate >= now && sub.renewalDate <= target
            }
            .sorted { $0.renewalDate < $1.renewalDate }
    }

    private var hasUpcoming: Bool {
        !renewingToday.isEmpty ||
        !overdueRenewalsList.isEmpty ||
        !upcomingRenewals(within: 7).isEmpty
    }

    // MARK: - Upcoming Section

    @ViewBuilder
    private var upcomingSection: some View {
        let today   = renewingToday
        let overdue = overdueRenewalsList
        let soon    = upcomingRenewals(within: 7)

        VStack(alignment: .leading, spacing: 14) {
            Text("home.upcoming.title", bundle: .main)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 10) {
                if !today.isEmpty {
                    upcomingGroupHeader("home.upcoming.today", color: .red)
                    ForEach(today) { sub in
                        upcomingRow(sub, accent: .red)
                    }
                }

                if !overdue.isEmpty {
                    upcomingGroupHeader("home.upcoming.missed", color: .orange)
                    ForEach(overdue) { sub in
                        upcomingRow(sub, accent: .orange)
                    }
                }

                if !soon.isEmpty {
                    upcomingGroupHeader("home.upcoming.within7days", color: .yellow)
                    ForEach(soon) { sub in
                        upcomingRow(sub, accent: .yellow)
                    }
                }
            }
        }
        .glassCard()
    }

    private func upcomingGroupHeader(_ key: LocalizedStringKey, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(key, bundle: .main)
                .font(.caption.weight(.semibold))
                .foregroundColor(.primary)
        }
    }

    private func upcomingRow(_ sub: Subscription, accent: Color) -> some View {
        HStack(spacing: 10) {
            if let service = sub.service {
                Image(service.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: "creditcard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(sub.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(sub.renewalDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task {
                    await scheduleReminderForSubscription(sub)
                }
            } label: {
                Text("home.remind", bundle: .main)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(accent.opacity(0.18))
                    .foregroundColor(accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
    
    private func scheduleReminderForSubscription(_ sub: Subscription) async {
        // Bildirim izni kontrol et
        let authorized = await NotificationScheduler.ensureAuthorization()
        guard authorized else {
            print("⚠️ Bildirim izni verilmedi")
            return
        }
        
        // Aboneliğin bildirim ayarlarını aktif et ve store'u güncelle
        // store.update içinde bildirim planlaması yapılıyor
        var updatedSub = sub
        updatedSub.notifyEnabled = true
        
        await MainActor.run {
            store.update(updatedSub)
        }
    }

    // MARK: - Subscriptions Section

    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("home.subscriptions.title", bundle: .main)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(store.items.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if store.items.isEmpty {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("home.empty.title", bundle: .main)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text("home.empty.description", bundle: .main)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button {
                        showAddSubscription = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("home.addSubscription", bundle: .main)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    VStack(spacing: 8) {
                        ForEach(store.items) { sub in
                            SwipeableSubscriptionRow(
                                sub: sub,
                                isOpen: openSwipeRowId == sub.id,
                                onEdit: { editingSub = sub },
                                onDelete: { deleteSub(sub) },
                                onSwipeChanged: { isOpen in
                                    openSwipeRowId = isOpen ? sub.id : nil
                                }
                            )
                        }
                    }
                    
                    // Full-width Add Subscription button
                    Button {
                        showAddSubscription = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("home.addSubscription", bundle: .main)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .glassCard()
    }

    private func deleteSub(_ sub: Subscription) {
        // Açık swipe'i kapat
        openSwipeRowId = nil
        
        guard let index = store.items.firstIndex(where: { $0.id == sub.id }) else { return }
        let offsets = IndexSet(integer: index)

        withAnimation(.easeInOut) {
            store.delete(at: offsets)
        }
    }

    // MARK: - Helpers
    
    private var notificationsEnabledSubscriptions: [Subscription] {
        store.items.filter { $0.notifyEnabled && store.notificationsEnabled }
    }
    
    // MARK: - Animations

    private func startAnimations() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
            appearHeader = true
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.85).delay(0.05)) {
            appearSummary = true
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.85).delay(0.10)) {
            appearUpcoming = true
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.85).delay(0.18)) {
            appearList = true
        }
    }
}

// MARK: - Swipeable satır (scroll ile çakışmayan, responsive)

struct SwipeableSubscriptionRow: View {
    let sub: Subscription
    let isOpen: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSwipeChanged: (Bool) -> Void

    @State private var offsetX: CGFloat = 0

    private let actionWidth: CGFloat = 90

    var body: some View {
        ZStack(alignment: .trailing) {
            // Sil butonu (arka planda, düzgün hizalı)
            HStack {
                Spacer()
                
                Button(action: {
                    onDelete()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                        Text("home.delete", bundle: .main)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: actionWidth, height: 70)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .opacity(offsetX < -20 ? 1.0 : 0)
                .allowsHitTesting(offsetX < -20)
            }
            .padding(.trailing, 20)
            .zIndex(1)

            // Ana içerik
            SubscriptionRowView(sub: sub)
                .padding(12)
                .frame(height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.systemBackground).opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .offset(x: offsetX)
                .contentShape(Rectangle())
                .zIndex(0)
                .onTapGesture {
                    if offsetX == 0 {
                        onEdit()
                    } else {
                        closeSwipe()
                    }
                }
        }
        .frame(height: 70)
        .clipped()
        .onChange(of: isOpen) { _, newValue in
            // Dışarıdan kapatıldığında
            if !newValue && offsetX < 0 {
                closeSwipe()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    let dx = value.translation.width
                    let dy = abs(value.translation.height)
                    let absDx = abs(dx)
                    
                    // Yatay hareket dikey hareketten en az 2.5x fazla olmalı
                    if absDx > dy * 2.5 {
                        if dx < 0 {
                            // Sola kaydırma
                            let clamped = max(dx, -actionWidth)
                            offsetX = clamped
                        } else if offsetX < 0 {
                            // Sağa kaydırma (kapatma)
                            let newOffset = max(offsetX + dx, -actionWidth)
                            offsetX = min(newOffset, 0)
                        }
                    } else if dy > 20 {
                        // Dikey scroll algılandı - scroll'a bırak
                        // Açıksa kapat
                        if offsetX < 0 {
                            closeSwipe()
                        }
                    }
                }
                .onEnded { value in
                    let dx = value.translation.width
                    let dy = abs(value.translation.height)
                    let absDx = abs(dx)
                    
                    if absDx > dy * 2.5 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            if dx < -50 {
                                // Aç
                                offsetX = -actionWidth
                                onSwipeChanged(true)
                            } else {
                                // Kapat
                                closeSwipe()
                            }
                        }
                    } else {
                        // Scroll - kapat
                        closeSwipe()
                    }
                }
        )
    }
    
    private func closeSwipe() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            offsetX = 0
        }
        onSwipeChanged(false)
    }
}
