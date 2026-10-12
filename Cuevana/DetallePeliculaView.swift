//
//  DetallePeliculaView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//
import SwiftUI

struct DetallePeliculaView: View {
    @Environment(FavoritosStore.self) var favoritos
    let pelicula: Pelicula

    var body: some View {
        let esFavorita = favoritos.esFavorita(pelicula)

        VStack(spacing: 20) {
            Image(systemName: "film.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)
                .padding()

            Text(pelicula.titulo)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text("\(pelicula.anio) • \(pelicula.genero)")
                .foregroundColor(.gray)

            Text(pelicula.sinopsis)
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                favoritos.alternar(pelicula)
            }) {
                Text(esFavorita ? "Quitar de Favoritos" : "Agregar a Favoritos")
                    .foregroundColor(.white)
                    .padding()
                    .background(esFavorita ? Color.red : Color.blue)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

#Preview {
    DetallePeliculaView(pelicula: peliculasEjemplo[0])
        .environment(FavoritosStore())
}
