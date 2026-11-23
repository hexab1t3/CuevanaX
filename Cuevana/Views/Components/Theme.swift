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

    @State private var start = Date()
    @State private var isVisible = false
    /// Cuándo se pausó el degradado; al reanudar se recorre `start` para que no brinque.
    @State private var pausedAt: Date?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private static let colors: [Color] = [
        Theme.background, Theme.violet.mix(with: Theme.background, by: 0.55), Theme.background,
        Theme.coral.mix(with: Theme.background, by: 0.7), Theme.background, Theme.violet.mix(with: Theme.background, by: 0.75),
        Theme.background, Theme.amber.mix(with: Theme.background, by: 0.8), Theme.background
    ]

    var body: some View {
        ZStack {
            if animated {
                // El centro del degradado va y viene cada 12 s. Se redibuja 20 veces por segundo;
                // antes se usaba repeatForever, que redibujaba toda la pantalla a la frecuencia
                // del monitor (hasta 120 veces por segundo) sin parar.
                TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: isMeshPaused)) { timeline in
                    mesh(shift: shift(at: timeline.date))
                }
                .ignoresSafeArea()
            } else {
                mesh(shift: 0)
            }

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
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .onChange(of: isMeshPaused, initial: true) { _, paused in
            guard animated else { return }
            if paused {
                if pausedAt == nil { pausedAt = Date() }
            } else if let pausedSince = pausedAt {
                start = start.addingTimeInterval(Date().timeIntervalSince(pausedSince))
                pausedAt = nil
            }
        }
    }

    /// Se pausa si no se ve, si la app no está activa o si el usuario pidió reducir el movimiento.
    private var isMeshPaused: Bool {
        !isVisible || reduceMotion || scenePhase != .active
    }

    /// `shift` va de 0 (centro abajo a la izquierda) a 1 (centro arriba a la derecha).
    private func mesh(shift: Float) -> some View {
        let center: SIMD2<Float> = [0.3 + 0.4 * shift, 0.6 - 0.25 * shift]
        let points: [SIMD2<Float>] = [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], center, [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ]
        return MeshGradient(width: 3, height: 3, points: points, colors: Self.colors)
            .ignoresSafeArea()
    }

    /// 0 → 1 → 0 cada 12 segundos, arrancando y frenando suave
    /// (igual que el easeInOut de 6 s de ida y 6 s de vuelta que había antes).
    private func shift(at date: Date) -> Float {
        let seconds = date.timeIntervalSince(start)
        return Float(0.5 - 0.5 * cos(seconds * .pi / 6))
    }
}
