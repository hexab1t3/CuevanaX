//
//  PeliculasView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI

struct MoviesView: View {
    
    @State private var viewModel = MoviesViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                Text("Películas en Cartelera")
                    .font(.title2)
                    .bold()
                    .padding()

                List(viewModel.movies) { movie in
                    NavigationLink(value: movie) {
                        HStack {
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .frame(width: 60, height: 80)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 5) {
                                Text(movie.title)
                                    .font(.headline)
                                Text("Calificación: \(movie.qualification, specifier: "%.1f")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Películas")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(movie: movie)
            }
        }
    }
}

#Preview {
    MoviesView()
        .environment(FavoritesStore())
}
