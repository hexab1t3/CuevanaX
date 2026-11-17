//
//  Theme.swift
//  Cuevana
//

import SwiftUI
import PixelKit

/// Colores y degradados compartidos por todas las pantallas.
enum Theme {
    static let background = Color(red: 0.04, green: 0.06, blue: 0.12)
    static let surface = Color(red: 0.08, green: 0.12, blue: 0.20)
    static let amber = Color(red: 1.0, green: 0.75, blue: 0.0)
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.33)
    static let violet = Color(red: 0.55, green: 0.32, blue: 0.98)
    static let deepViolet = Color(red: 0.29, green: 0.17, blue: 0.63)
    static let lilac = Color(red: 0.78, green: 0.69, blue: 1.0)

    static let brandGradient = LinearGradient(
        colors: [amber, coral, violet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let imageShade = LinearGradient(
        colors: [.clear, .black.opacity(0.85)],
        startPoint: .top,
        endPoint: .bottom
    )
}

/// Fondo con degradado de malla y mosaico pixel; en el login el degradado se anima lentamente.
struct AmbientBackground: View {
    var animated = false
    @State private var isShifted = false

    private static let colors: [Color] = [
        Theme.background, Theme.violet.mix(with: Theme.background, by: 0.55), Theme.background,
        Theme.coral.mix(with: Theme.background, by: 0.7), Theme.background, Theme.violet.mix(with: Theme.background, by: 0.75),
        Theme.background, Theme.amber.mix(with: Theme.background, by: 0.8), Theme.background
    ]

    private var points: [SIMD2<Float>] {
        let center: SIMD2<Float> = isShifted ? [0.7, 0.35] : [0.3, 0.6]
        return [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], center, [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ]
    }

    var body: some View {
        ZStack {
            MeshGradient(width: 3, height: 3, points: points, colors: Self.colors)
                .ignoresSafeArea()

            // Mosaico pixel de nuestra librería PixelKit, encima del degradado.
            PixelMosaicView(
                darkColor: Theme.deepViolet,
                lightColor: Theme.violet,
                sparkleColor: Theme.lilac,
                cell: 10,
                speed: 0.5,
                brightness: 0.8
            )
        }
        .onAppear {
            guard animated else { return }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                isShifted.toggle()
            }
        }
    }
}
