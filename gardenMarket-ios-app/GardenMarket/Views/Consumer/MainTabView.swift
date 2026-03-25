import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ListingsGridView()
                .tabItem { Label("Browse", systemImage: "leaf") }
            CartView()
                .tabItem { Label("Cart", systemImage: "cart") }
            OrdersListView()
                .tabItem { Label("Orders", systemImage: "bag") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
