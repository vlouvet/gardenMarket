import SwiftUI

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = OrderViewModel()
    @State private var selectedCenter: DistributionCenter?
    @State private var pickupWindow = ""
    @State private var pickupDate = Date()
    @State private var includeDate = false
    var onComplete: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Distribution Center") {
                    if viewModel.centers.isEmpty {
                        ProgressView("Loading centers...")
                    } else {
                        Picker("Center", selection: $selectedCenter) {
                            Text("Select a center").tag(nil as DistributionCenter?)
                            ForEach(viewModel.centers) { center in
                                Text("\(center.name) - \(center.city)")
                                    .tag(center as DistributionCenter?)
                            }
                        }
                    }
                }

                Section("Pickup Details") {
                    TextField("Pickup window (e.g. Morning)", text: $pickupWindow)

                    Toggle("Set pickup date", isOn: $includeDate)
                    if includeDate {
                        DatePicker("Date", selection: $pickupDate, displayedComponents: .date)
                    }
                }

                if let error = viewModel.error {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        guard let center = selectedCenter else { return }
                        let dateStr = includeDate ? formatDate(pickupDate) : nil
                        Task {
                            await viewModel.createOrder(
                                centerId: center.id,
                                pickupWindow: pickupWindow,
                                pickupDate: dateStr
                            )
                            if viewModel.orderCreated != nil {
                                onComplete()
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            HStack { Spacer(); ProgressView(); Spacer() }
                        } else {
                            Text("Place Order")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(selectedCenter == nil || viewModel.isLoading)
                }
            }
            .navigationTitle("Checkout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task { await viewModel.loadCenters() }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

extension DistributionCenter: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public static func == (lhs: DistributionCenter, rhs: DistributionCenter) -> Bool { lhs.id == rhs.id }
}
