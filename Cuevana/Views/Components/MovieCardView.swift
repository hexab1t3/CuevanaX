//
//  MovieCardView.swift
//  Cuevana
//

import SwiftUI

/// Tarjeta del grid tipo Pinterest. Su proporción es fija para que el grid no brinque al cargar las imágenes.
struct MovieCardView: View {
    enum Style {
        case poster
        case scene
    }

    let movie: Movie
    var style: Style = .poster

    private var imageURL: URL? {
        style == .scene ? (movie.backdropURL ?? movie.posterURL) : movie.posterURL
    }

    var body: some View {
        Color.clear
            .aspectRatio(style == .scene ? 1 : 2 / 3, contentMode: .fit)
            .overlay {
                MovieImageView(url: imageURL)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(movie.title)
                        .font(.pixelify(.subheadline, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(String(movie.year))
                        .font(.pixelify(.caption))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .padding(.top, 24)
                .background(Theme.imageShade)
            }
            .overlay(alignment: .topTrailing) {
                RatingBadge(rating: movie.qualification)
                    .padding(8)
            }
            .clipShape(.rect(cornerRadius: 20))
            .contentShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
    }
}

struct RatingBadge: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .foregroundStyle(Theme.amber)
            Text(String(format: "%.1f", rating))
                .foregroundStyle(.white)
        }
        .font(.pixelify(.caption, weight: .bold))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: .capsule)
    }
}

/// Mensaje centrado para los estados vacío y de error, con botón opcional para reintentar.
struct StatusMessageView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(Theme.brandGradient)
                .symbolEffect(.breathe)

            Text(title)
                .font(.pixelify(.title3, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.pixelify(.subheadline))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let buttonTitle, let action {
                Button(action: action) {
                    Label(buttonTitle, systemImage: "arrow.clockwise")
                        .font(.pixelify(.headline, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glassProminent)
                .tint(Theme.amber)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
