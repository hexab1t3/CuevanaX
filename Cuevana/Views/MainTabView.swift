//
//  MainTabView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct MainTabView: View {
    @Binding var isAuthenticated: Bool
    @Environment(FavoritesStore.self) var favorites

    var body: some View {
        TabView {
            Tab("Películas", systemImage: "film") {
                MoviesView()
            }

            Tab("Favoritos", systemImage: "heart") {
                FavoritesView()
            }

            Tab("Perfil", systemImage: "person") {
                ProfileView(isAuthenticated: $isAuthenticated)
            }

            Tab("Buscar", systemImage: "magnifyingglass", role: .search) {
                FindView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Theme.amber)
    }
}

#Preview {
    MainTabView(isAuthenticated: .constant(true))
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}
