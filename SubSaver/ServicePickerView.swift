import SwiftUI

struct ServicePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: ServiceItem?

    @State private var query: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { item in
                    Button {
                        selected = item
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 34, height: 34)
                                .background(item.accent.opacity(0.15))
                                .foregroundStyle(item.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            Text(item.name)
                            Spacer()

                            if selected?.name == item.name {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Hizmet Seç")
            .searchable(text: $query, prompt: "Ara")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }

    private var filtered: [ServiceItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return ServiceCatalog.popular }
        return ServiceCatalog.popular.filter { $0.name.lowercased().contains(q) }
    }
}

