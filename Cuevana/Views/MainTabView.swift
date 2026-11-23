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

            // Sin role: .search, para que Buscar quede dentro de la barra como las demás pestañas
            Tab("Buscar", systemImage: "magnifyingglass") {
                FindView()
            }
        }
        .tabBarMinimizeBehavior(.never)   // la barra de pestañas siempre se ve completa, nunca se encoge
        .tint(Theme.amber)
    }
}

#Preview {
    MainTabView(isAuthenticated: .constant(true))
        .environment(FavoritesStore(container: FavoritesStore.inMemoryContainer()))
}
