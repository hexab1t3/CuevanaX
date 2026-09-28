//
//  FavoritosView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct FavoritosView: View {
    var body: some View {
        VStack {
            Text("Tus Favoritos")
                .font(.title2)
                .bold()
                .padding()

            let favoritas = peliculasEjemplo.filter { $0.esFavorita }

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
                    Text(pelicula.titulo)
                }
            }
        }
    }
}

#Preview {
    FavoritosView()
}

