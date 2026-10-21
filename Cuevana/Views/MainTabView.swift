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
            MoviesView()
                .tabItem {
                    Image(systemName: "film")
                    Text("Películas")
                }

            FindView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favoritos")
                }
                .badge(favorites.ids.count)

            ProfileView(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Image(systemName: "person")
                    Text("Perfil")
                }
        }
    }
}

#Preview {
    MainTabView(isAuthenticated: .constant(true))
        .environment(FavoritesStore())
}
