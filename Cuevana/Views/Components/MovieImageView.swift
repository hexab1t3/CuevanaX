//
//  MovieImageView.swift
//  Cuevana
//

import SwiftUI

/// Imagen remota que llena su espacio sin deformarse, con carga animada y respaldo si falla.
struct MovieImageView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.35))) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            case .failure:
                fallback
            default:
                if url == nil {
                    fallback
                } else {
                    ShimmerView()
                }
            }
        }
    }

    private var fallback: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.violet.mix(with: Theme.background, by: 0.5), Theme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

/// Bloque que pulsa mientras llega el contenido.
struct ShimmerView: View {
    var body: some View {
        Rectangle()
            .fill(Theme.surface)
            .phaseAnimator([false, true]) { content, isBright in
                content.opacity(isBright ? 1 : 0.45)
            } animation: { _ in
                .easeInOut(duration: 0.9)
            }
    }
}
