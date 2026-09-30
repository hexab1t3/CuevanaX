//
//  PeliculasView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct PeliculasView: View {
    @State private var peliculaSeleccionada: Pelicula?

    var body: some View {
        VStack {
            Text("Películas en Cartelera")
                .font(.title2)
                .bold()
                .padding()

            List(peliculasEjemplo) { pelicula in
                Button(action: {
                    peliculaSeleccionada = pelicula
                }) {
                    HStack {
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(width: 60, height: 80)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(pelicula.titulo)
                                .font(.headline)
                            Text("Calificación: \(pelicula.calificacion, specifier: "%.1f")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .sheet(item: $peliculaSeleccionada) { pelicula in
            DetallePeliculaView(pelicula: pelicula)
        }
    }
}

#Preview {
    PeliculasView()
}
