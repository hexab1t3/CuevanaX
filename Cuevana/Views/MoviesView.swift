//
//  PeliculasView.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import SwiftUI
import WaterfallGrid

struct MoviesView: View {
    
    @State private var viewModel = MoviesViewModel()
    
    // Colores personalizados para el tema nocturno
    private let deepNavyBackground = Color(red: 0.04, green: 0.06, blue: 0.12)
    private let cardBackground = Color(red: 0.08, green: 0.12, blue: 0.20)
    private let amberAccent = Color(red: 1.0, green: 0.75, blue: 0.0) // Tono ámbar cálido y brillante
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo general de la app (azul marino profundo)
                deepNavyBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("Películas en Cartelera")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        // 1. BANNER DESTACADO (Película del día)
                        if let featuredMovie = viewModel.movies.first {
                            NavigationLink(value: featuredMovie) {
                                ZStack(alignment: .bottomLeading) {
                                    AsyncImage(url: featuredMovie.posterURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(height: 230)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(16)
                                    .overlay(
                                        LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                                            .cornerRadius(16)
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("PELÍCULA DESTACADA")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.red)
                                            .cornerRadius(4)
                                            .foregroundColor(.white)
                                        
                                        Text(featuredMovie.title)
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                        // Estrellita de color ámbar
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(amberAccent)
                                            Text(String(format: "%.1f", featuredMovie.qualification))
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Películas Populares")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // 2. GRID EN CASCADA CON PÓSTERS REALES
                        if viewModel.isLoading {
                            ProgressView("Cargando películas...")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            WaterfallGrid(viewModel.movies) { movie in
                                NavigationLink(value: movie) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        AsyncImage(url: movie.posterURL) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .aspectRatio(2/3, contentMode: .fit)
                                                .overlay(ProgressView())
                                        }
                                        .cornerRadius(8)

                                        Text(movie.title)
                                            .font(.headline)
                                            .lineLimit(2)
                                            .foregroundColor(.white)
                                        
                                        // Estrellas de calificación con color ámbar
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(amberAccent)
                                            
                                            Text(String(format: "%.1f", movie.qualification))
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(8)
                                    .background(cardBackground)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                                }
                            }
                            .gridStyle(
                                columnsInPortrait: 2,
                                columnsInLandscape: 3,
                                spacing: 12
                            )
                            .padding(.horizontal)
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
        .preferredColorScheme(.dark)
    }
}
