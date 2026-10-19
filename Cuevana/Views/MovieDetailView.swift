//
//  DetallePeliculaView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//
import SwiftUI

struct MovieDetailView: View {
    @Environment(FavoritesStore.self) var favoritesStore
    @State private var viewModel: MovieDetailViewModel
    
    init(movie: Movie) {
            _viewModel = State(initialValue: MovieDetailViewModel(movie: movie))
        }

    var body: some View {
        let isFavorite = favoritesStore.isFavorite(viewModel.movie)

        VStack(spacing: 20) {
            Image(systemName: "film.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)
                .padding()

            Text(viewModel.movie.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text("\(viewModel.movie.year) • \(viewModel.movie.gender)")
                .foregroundColor(.gray)

            Text(viewModel.movie.sinopsis)
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                favoritesStore.alternate(viewModel.movie)
            }) {
                Text(isFavorite ? "Quitar de Favoritos" : "Agregar a Favoritos")
                    .foregroundColor(.white)
                    .padding()
                    .background(isFavorite ? Color.red : Color.blue)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

#Preview {
    MovieDetailView(movie: ExampleMovies[0])
        .environment(FavoritesStore())
}
