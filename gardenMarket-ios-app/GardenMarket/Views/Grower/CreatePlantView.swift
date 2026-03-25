import SwiftUI

struct CreatePlantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GrowerDashboardViewModel()
    @State private var name = ""
    @State private var species = ""
    @State private var description = ""
    @State private var tags = ""
    @State private var growMethod = "SOIL"
    var onCreated: () -> Void

    private let methods = [("SOIL", "Soil"), ("HYDROPONIC", "Hydroponic"), ("AQUAPONIC", "Aquaponic"), ("ORGANIC", "Organic")]

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant Info") {
                    TextField("Name", text: $name)
                    TextField("Species", text: $species)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Tags (comma-separated)", text: $tags)
                }

                Section("Grow Method") {
                    Picker("Method", selection: $growMethod) {
                        ForEach(methods, id: \.0) { val, label in Text(label).tag(val) }
                    }
                    .pickerStyle(.segmented)
                }

                if let error = viewModel.error {
                    Section { Text(error).foregroundStyle(.red) }
                }

                Section {
                    Button("Create Plant") {
                        guard let gardener = viewModel.gardenerProfile?.id else {
                            viewModel.error = "Gardener profile not found."
                            return
                        }
                        Task {
                            await viewModel.createPlant(CreatePlantRequest(
                                gardener: gardener,
                                name: name,
                                species: species,
                                description: description,
                                tags: tags,
                                growMethod: growMethod
                            ))
                            if viewModel.error == nil {
                                onCreated()
                                dismiss()
                            }
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("New Plant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task { await viewModel.loadGardenerProfile() }
        }
    }
}
