import SwiftUI

struct ListingFilterBar: View {
    @Binding var filter: ListingFilter
    var onApply: () -> Void

    private let types = [("", "All"), ("PRODUCE", "Produce"), ("SEEDS", "Seeds"), ("CLIPPING", "Clippings")]

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(types, id: \.0) { value, label in
                        Button(label) {
                            filter.type = value.isEmpty ? nil : value
                            onApply()
                        }
                        .buttonStyle(.bordered)
                        .tint(filter.type == (value.isEmpty ? nil : value) ? .accentColor : .secondary)
                    }
                }
            }

            HStack {
                TextField("Search by address...", text: Binding(
                    get: { filter.address ?? "" },
                    set: { filter.address = $0.isEmpty ? nil : $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .onSubmit { onApply() }

                Toggle("In stock", isOn: Binding(
                    get: { filter.inStock ?? false },
                    set: {
                        filter.inStock = $0 ? true : nil
                        onApply()
                    }
                ))
                .toggleStyle(.button)
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }
}
