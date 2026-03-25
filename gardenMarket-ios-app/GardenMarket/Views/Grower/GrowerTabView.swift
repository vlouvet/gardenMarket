import SwiftUI

struct GrowerTabView: View {
    var body: some View {
        TabView {
            ListingsGridView()
                .tabItem { Label("Browse", systemImage: "leaf") }
            GrowerListingsView()
                .tabItem { Label("My Listings", systemImage: "list.bullet") }
            PlantsListView()
                .tabItem { Label("Plants", systemImage: "camera.macro") }
            GrowerOrdersView()
                .tabItem { Label("Orders", systemImage: "bag") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
