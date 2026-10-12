//
//  FavoritosView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct FavoritosView: View {
    @Environment(FavoritosStore.self) var favoritos

    var body: some View {
        NavigationStack {
            VStack {
                Text("Tus Favoritos")
                    .font(.title2)
                    .bold()
                    .padding()

                let favoritas = peliculasEjemplo.filter { favoritos.esFavorita($0) }

                if favoritas.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Text("💔")
                            .font(.system(size: 80))
                        Text("No tienes películas favoritas")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List(favoritas) { pelicula in
                        NavigationLink(value: pelicula) {
                            Text(pelicula.titulo)
                        }
                    }
                }
            }
            .navigationTitle("Favoritos")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Pelicula.self) { pelicula in
                DetallePeliculaView(pelicula: pelicula)
            }
        }
    }
}

#Preview {
    FavoritosView()
        .environment(FavoritosStore())
}
