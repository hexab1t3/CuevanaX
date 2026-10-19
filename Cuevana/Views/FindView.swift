//
//  BuscarView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct FindView: View {
    @State private var viewModel = FindViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Buscar Películas")
                    .font(.title2)
                    .bold()
                    .padding()

                TextField("Escribe el nombre de la película...", text: $viewModel.searchText)
                    .padding()
                    .background(Color(.systemGray2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Spacer()

                if viewModel.filteredMovies.isEmpty {
                    VStack(spacing: 20) {
                        Text("🍿")
                            .font(.system(size: 80))
                        Text("Busca una película")
                            .foregroundColor(.gray)
                    }
                } else {
                    List(viewModel.filteredMovies) { movie in
                        NavigationLink(value: movie) {
                            Text(movie.title)
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Buscar")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
}

#Preview {
    FindView()
        .environment(FavoritesStore())
}
