//
//  DetallePeliculaView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//
import SwiftUI

struct DetallePeliculaView: View {
    @Environment(\.dismiss) var dismiss
    let pelicula: Pelicula
    @State private var esFavorita = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button("Cerrar") {
                    dismiss()
                }
                .padding()
            }

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
                esFavorita.toggle()
                // Actualizamos el array global para que se refleje en FavoritosView
                if let index = peliculasEjemplo.firstIndex(where: { $0.id == pelicula.id }) {
                    peliculasEjemplo[index].esFavorita = esFavorita
                }
            }) {
                Text(esFavorita ? "Quitar de Favoritos" : "Agregar a Favoritos")
                    .foregroundColor(.white)
                    .padding()
                    .background(esFavorita ? Color.red : Color.blue)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .onAppear {
            self.esFavorita = pelicula.esFavorita
        }
    }
}

#Preview {
    DetallePeliculaView(pelicula: peliculasEjemplo[0])
}

