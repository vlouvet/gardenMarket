import SwiftUI

struct PlantsListView: View {
    @State private var viewModel = GrowerDashboardViewModel()
    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.plants.isEmpty {
                    ContentUnavailableView("No Plants", systemImage: "camera.macro", description: Text("Add your first plant profile."))
                } else {
                    List(viewModel.plants) { plant in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plant.name)
                                .font(.headline)
                            if let species = plant.species, !species.isEmpty {
                                Text(species)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Text(plant.displayGrowMethod)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Plants")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreate = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                CreatePlantView {
                    Task { await viewModel.loadPlants() }
                }
            }
            .task { await viewModel.loadPlants() }
        }
    }
}
