//
//  MainTabView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct MainTabView: View {
    @Binding var estaAutenticado: Bool

    var body: some View {
        TabView {
            PeliculasView()
                .tabItem {
                    Image(systemName: "film")
                    Text("Películas")
                }

            BuscarView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Buscar")
                }

            FavoritosView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favoritos")
                }

            PerfilView(estaAutenticado: $estaAutenticado)
                .tabItem {
                    Image(systemName: "person")
                    Text("Perfil")
                }
        }
    }
}

#Preview {
    MainTabView(estaAutenticado: .constant(true))
}
