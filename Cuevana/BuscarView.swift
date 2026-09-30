//
//  BuscarView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct BuscarView: View {
    @State private var textoBusqueda = ""

    var body: some View {
        VStack {
            Text("Buscar Películas")
                .font(.title2)
                .bold()
                .padding()

            TextField("Escribe el nombre de la película...", text: $textoBusqueda)
                .padding()
                .background(Color(.systemGray2))
                .cornerRadius(10)
                .padding(.horizontal)

            Spacer()

            if textoBusqueda.isEmpty {
                VStack(spacing: 20) {
                    Text("🍿")
                        .font(.system(size: 80))
                    Text("Busca una película")
                        .foregroundColor(.gray)
                }
            } else {
                List(peliculasEjemplo.filter { $0.titulo.lowercased().contains(textoBusqueda.lowercased()) }) { pelicula in
                    Text(pelicula.titulo)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    BuscarView()
}
