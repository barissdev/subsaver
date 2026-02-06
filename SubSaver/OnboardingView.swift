import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var page = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.96, blue: 1.0),
                    Color(red: 0.86, green: 0.92, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        hasSeenOnboarding = true
                    } label: {
                        Text("onboarding.skip", bundle: .main)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                    .opacity(page == 1 ? 0 : 1)
                }

                TabView(selection: $page) {
                    pageView(
                        title: "onboarding.page1.title",
                        subtitle: "onboarding.page1.subtitle",
                        systemImage: "creditcard"
                    )
                    .tag(0)

                    lastPageView(
                        title: "onboarding.page2.title",
                        subtitle: "onboarding.page2.subtitle",
                        systemImage: "bell.badge"
                    )
                    .tag(1)
                }
                .tabViewStyle(.page)

                if page < 1 {
                    Button {
                        withAnimation { page += 1 }
                    } label: {
                        Text("onboarding.continue", bundle: .main)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)
                }
            }
        }
    }

    private func pageView(title: LocalizedStringKey, subtitle: LocalizedStringKey, systemImage: String) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 56, weight: .semibold))

            Text(title, bundle: .main)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(subtitle, bundle: .main)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.vertical, 24)
    }

    private func lastPageView(title: LocalizedStringKey, subtitle: LocalizedStringKey, systemImage: String) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 56, weight: .semibold))

            Text(title, bundle: .main)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(subtitle, bundle: .main)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            Button {
                Task {
                    await requestPermissions()
                    hasSeenOnboarding = true
                }
            } label: {
                Text("onboarding.start", bundle: .main)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
        }
        .padding(.vertical, 24)
    }

    private func requestPermissions() async {
        // Bildirim izni iste
        _ = await NotificationScheduler.ensureAuthorization()
    }
}
