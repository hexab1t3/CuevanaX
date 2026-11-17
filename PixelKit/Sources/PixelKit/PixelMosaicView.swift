import SwiftUI

/// Fondo animado tipo mosaico: una cuadrícula de cuadritos con franjas de color
/// que se desplazan despacio y algunos cuadritos que destellan de vez en cuando.
/// Los colores los decide la app que usa la librería.
public struct PixelMosaicView: View {
    private let sparkleColor: Color
    private let bandColors: [Color]     // 4 tonos entre darkColor y lightColor
    private let cell: Double
    private let speed: Double
    private let brightness: Double

    /// Momento en que apareció la vista; la animación se calcula a partir de aquí.
    @State private var start = Date()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - darkColor: color de las franjas más oscuras.
    ///   - lightColor: color de las franjas más claras.
    ///   - sparkleColor: color de los cuadritos que destellan.
    ///   - cell: lado de cada cuadrito, en puntos.
    ///   - speed: velocidad de la animación (1 = normal, 0 = quieta).
    ///   - brightness: qué tan visibles son los cuadritos (0 a 1 o un poco más).
    public init(
        darkColor: Color,
        lightColor: Color,
        sparkleColor: Color,
        cell: Double = 10,
        speed: Double = 0.5,
        brightness: Double = 0.8
    ) {
        self.sparkleColor = sparkleColor
        // Se calculan una sola vez los 4 tonos de las franjas, del más oscuro al más claro.
        self.bandColors = (0...3).map { step in
            darkColor.mix(with: lightColor, by: Double(step) / 3)
        }
        self.cell = max(cell, 4)
        self.speed = speed
        self.brightness = brightness
    }

    public var body: some View {
        // TimelineView redibuja unas 30 veces por segundo; se pausa si el usuario pidió reducir el movimiento.
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince(start) * speed
                drawMosaic(in: context, size: size, time: time)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Dibujo

    private func drawMosaic(in context: GraphicsContext, size: CGSize, time: Double) {
        let columns = Int((Double(size.width) / cell).rounded(.up))
        let rows = Int((Double(size.height) / cell).rounded(.up))

        for row in 0..<rows {
            for column in 0..<columns {
                let x = Double(column)
                let y = Double(row)
                let noise = random(column, row)              // decide el brillo del cuadrito y si destella
                let timing = random(column + 500, row + 900)  // otro número, independiente: decide CUÁNDO destella

                // 1. Franjas: dos ondas que se mueven en diagonal, redondeadas a 4 tonos.
                let wave1: Double = sin(x * 0.16 + y * 0.035 - time * 0.5)
                let wave2: Double = sin(x * 0.07 - y * 0.02 + time * 0.3 + 1.7)
                let wave: Double = 0.5 + 0.25 * wave1 + 0.25 * wave2       // queda entre 0 y 1
                let bandIndex = min(Int(wave * 4), 3)                       // 0, 1, 2 o 3
                let band = Double(bandIndex) / 3

                // 2. Cada cuadrito "respira" a su propio ritmo; el 6 % de ellos destella.
                //    El ritmo usa `timing` y no `noise`: si usara `noise`, todos los que destellan
                //    (noise > 0.94) tendrían casi el mismo ritmo y prenderían a la vez.
                let breath: Double = 0.5 + 0.5 * sin(time * (0.8 + timing * 1.4) + timing * 40)
                let spark: Double = noise > 0.94 ? pow(breath, 6) : 0

                // 3. Color de la franja; si destella, se mezcla con el color de destello.
                var color = bandColors[bandIndex]
                if spark > 0 {
                    color = color.mix(with: sparkleColor, by: spark)
                }

                // 4. Opacidad: base tenue + franja + respiración + destello.
                let baseGlow: Double = 0.07 + 0.17 * band * (0.65 + 0.35 * noise)
                let opacity: Double = (baseGlow + 0.08 * breath * noise + 0.45 * spark) * brightness

                // 5. Cada cuadrito deja 1 punto de separación: eso dibuja la rejilla.
                let square = CGRect(x: x * cell + 0.5, y: y * cell + 0.5, width: cell - 1, height: cell - 1)
                context.fill(Path(square), with: .color(color.opacity(min(opacity, 1))))
            }
        }
    }

    /// Número pseudoaleatorio entre 0 y 1 que siempre es el mismo para la misma columna y fila.
    /// Así cada cuadrito tiene su propio brillo y no "parpadea" al azar en cada cuadro.
    private func random(_ column: Int, _ row: Int) -> Double {
        var h = UInt32(truncatingIfNeeded: column) &* 374_761_393     // &* multiplica sin error de desbordamiento
        h = h &+ UInt32(truncatingIfNeeded: row) &* 668_265_263
        h = (h ^ (h >> 13)) &* 1_274_126_177                          // mezcla los bits
        h = h ^ (h >> 16)
        return Double(h) / Double(UInt32.max)
    }
}

#Preview("Azul") {
    ZStack {
        Color.black.ignoresSafeArea()
        PixelMosaicView(darkColor: .indigo, lightColor: .cyan, sparkleColor: .white)
    }
}

#Preview("Verde") {
    ZStack {
        Color.black.ignoresSafeArea()
        PixelMosaicView(darkColor: Color(red: 0, green: 0.25, blue: 0.1), lightColor: .green, sparkleColor: .yellow)
    }
}
