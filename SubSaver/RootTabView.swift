import SwiftUI

enum MainTab {
    case subscriptions
    case statistics
    case settings
}

// Environment key for tab selection
struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<MainTab> = .constant(.subscriptions)
}

extension EnvironmentValues {
    var selectedTab: Binding<MainTab> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

struct RootTabView: View {
    @State private var selectedTab: MainTab = .subscriptions

    var body: some View {
        ZStack(alignment: .bottom) {

            // ANA İÇERİK
            Group {
                switch selectedTab {
                case .subscriptions:
                    HomeView()
                        .environment(\.selectedTab, $selectedTab)
                case .statistics:
                    StatisticsView()
                        .environment(\.selectedTab, $selectedTab)
                case .settings:
                    SettingsView()
                        .environment(\.selectedTab, $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // FLOATING TAB BAR
            HStack(spacing: 14) {
                tabButton(for: .subscriptions,
                          titleKey: "tab.subscriptions",
                          systemImage: "creditcard")

                tabButton(for: .statistics,
                          titleKey: "tab.statistics",
                          systemImage: "chart.bar.xaxis")

                tabButton(for: .settings,
                          titleKey: "tab.settings",
                          systemImage: "gearshape")
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.72)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.secondarySystemBackground))   // hafif açık pill
            )
            .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        // sadece içerik için systemBackground, barın dışında ekstra layer yok
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Tab Button

    private func tabButton(for tab: MainTab,
                           titleKey: LocalizedStringKey,
                           systemImage: String) -> some View {
        let isSelected = (tab == selectedTab)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                if isSelected {
                    Text(titleKey, bundle: .main)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundColor(isSelected ? Color.blue : Color.primary)
            .padding(.horizontal, isSelected ? 14 : 10)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color(.systemBlue).opacity(0.15))
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}
