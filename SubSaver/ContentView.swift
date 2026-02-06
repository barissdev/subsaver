import SwiftUI

struct ContentView: View {
    @StateObject private var store = SubscriptionStore()

    var body: some View {
        TabView {
            // 1) Abonelikler
            HomeView()
                .environmentObject(store)
                .tabItem {
                    Label("Abonelikler", systemImage: "creditcard")
                }

            // 2) İstatistik
            StatisticsView()
                .environmentObject(store)
                .tabItem {
                    Label("İstatistik", systemImage: "chart.bar.doc.horizontal")
                }

            // 3) Ayarlar
            SettingsView()
                .environmentObject(store)
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape")
                }
        }
    }
}
