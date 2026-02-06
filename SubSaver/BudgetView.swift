import SwiftUI

struct BudgetView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("Bütçe Takibi")
                    .font(.title2.bold())
                Text("Bir sonraki adımda aylık limit, kategoriler ve uyarılar ekleyeceğiz.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Bütçe")
        }
    }
}

