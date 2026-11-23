import SwiftUI

/// Fondo animado tipo mosaico: una cuadrícula de cuadritos con franjas de color
/// que se desplazan despacio y algunos cuadritos que destellan de vez en cuando.
/// Los colores los decide la app que usa la librería.
///
/// Rendimiento:
/// - Los cuadritos del mismo color y opacidad se juntan en un solo `Path`, así cada cuadro
///   hace unas decenas de `fill` en vez de uno por cuadrito (miles).
/// - Los colores (franjas × destellos) se calculan una sola vez, no en cada cuadro.
/// - Redibuja pocas veces por segundo (`framesPerSecond`), porque el movimiento es muy lento.
/// - Se pausa sola cuando no se ve en pantalla, cuando la app no está activa
///   o cuando el usuario pidió reducir el movimiento.
public struct PixelMosaicView: View {
    private let cell: Double
    private let speed: Double
    private let brightness: Double
    private let framesPerSecond: Double
    private let verticalFade: ClosedRange<Double>?
    /// Colores ya mezclados: para cada franja, todos sus niveles de destello.
    /// Índice = franja * sparkLevels + nivel de destello.
    private let palette: [Color]

    /// Momento en que apareció la vista; la animación se calcula a partir de aquí.
    @State private var start = Date()
    /// Solo se anima mientras la vista está en pantalla (otra pestaña o una pantalla encima la pausan).
    @State private var isVisible = false
    /// Cuándo se pausó; al reanudar se recorre `start` para seguir desde el mismo cuadro, sin saltos.
    @State private var pausedAt: Date?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private static let bandCount = 4      // tonos de las franjas, del más oscuro al más claro
    private static let sparkLevels = 8    // pasos de mezcla con el color de destello
    private static let opacityLevels = 64 // pasos de opacidad; a simple vista no se notan los saltos

    /// - Parameters:
    ///   - darkColor: color de las franjas más oscuras.
    ///   - lightColor: color de las franjas más claras.
    ///   - sparkleColor: color de los cuadritos que destellan.
    ///   - cell: lado de cada cuadrito, en puntos.
    ///   - speed: velocidad de la animación (1 = normal, 0 = quieta).
    ///   - brightness: qué tan visibles son los cuadritos (0 a 1 o un poco más).
    ///   - framesPerSecond: cuántas veces por segundo se redibuja (de 1 a 60). Con 15 se ve fluido
    ///     porque el movimiento es lento, y gasta la mitad que con 30.
    ///   - verticalFade: si se indica, el mosaico es invisible arriba y aparece de forma gradual:
    ///     invisible en `lowerBound` y completo en `upperBound` (fracciones de la altura, de 0 a 1).
    ///     Es más barato que ponerle `.mask` con un degradado, porque no crea otra capa en cada cuadro.
    public init(
        darkColor: Color,
        lightColor: Color,
        sparkleColor: Color,
        cell: Double = 10,
        speed: Double = 0.5,
        brightness: Double = 0.8,
        framesPerSecond: Double = 15,
        verticalFade: ClosedRange<Double>? = nil
    ) {
        // Se calculan una sola vez todos los colores posibles: 4 tonos de franja,
        // cada uno con 8 niveles de mezcla hacia el color de destello.
        var palette: [Color] = []
        palette.reserveCapacity(Self.bandCount * Self.sparkLevels)
        for band in 0..<Self.bandCount {
            let bandColor = darkColor.mix(with: lightColor, by: Double(band) / Double(Self.bandCount - 1))
            for level in 0..<Self.sparkLevels {
                let amount = Double(level) / Double(Self.sparkLevels - 1)
                palette.append(level == 0 ? bandColor : bandColor.mix(with: sparkleColor, by: amount))
            }
        }
        self.palette = palette
        self.cell = max(cell, 4)
        self.speed = speed
        self.brightness = brightness
        self.framesPerSecond = min(max(framesPerSecond, 1), 60)
        self.verticalFade = verticalFade
    }

    public var body: some View {
        let isPaused = reduceMotion || speed == 0 || !isVisible || scenePhase != .active

        // TimelineView da la hora actual unas `framesPerSecond` veces por segundo; en pausa deja el último cuadro.
        TimelineView(.animation(minimumInterval: 1.0 / framesPerSecond, paused: isPaused)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince(start) * speed
                drawMosaic(in: context, size: size, time: time)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .onChange(of: isPaused, initial: true) { _, paused in
            if paused {
                if pausedAt == nil { pausedAt = Date() }
            } else if let pausedSince = pausedAt {
                // Se descuenta el tiempo en pausa: la animación sigue donde se quedó, no brinca.
                start = start.addingTimeInterval(Date().timeIntervalSince(pausedSince))
                pausedAt = nil
            }
        }
    }

    // MARK: - Dibujo

    private func drawMosaic(in context: GraphicsContext, size: CGSize, time: Double) {
        let width = Double(size.width)
        let height = Double(size.height)
        guard width > 0, height > 0 else { return }

        let columns = Int((width / cell).rounded(.up))
        let rows = Int((height / cell).rounded(.up))
        let sparkLevels = Self.sparkLevels
        let opacityLevels = Self.opacityLevels

        // Una "cubeta" por cada combinación de color y opacidad. Cada cuadrito se agrega
        // al Path de su cubeta y al final se pinta cada cubeta con un solo `fill`.
        let bucketCount = palette.count * opacityLevels
        var paths = [Path](repeating: Path(), count: bucketCount)
        var used = [Bool](repeating: false, count: bucketCount)

        // Lo que solo depende del tiempo se calcula una vez por cuadro, no por cuadrito.
        let shift1: Double = time * 0.5
        let shift2: Double = time * 0.3 + 1.7

        for row in 0..<rows {
            let y = Double(row)

            // Desvanecido vertical opcional: las filas que quedan invisibles ni se calculan.
            var fade: Double = 1
            if let verticalFade {
                let position = (y + 0.5) * cell / height
                let span = max(verticalFade.upperBound - verticalFade.lowerBound, 0.0001)
                fade = min(max((position - verticalFade.lowerBound) / span, 0), 1)
                if fade <= 0 { continue }
            }

            for column in 0..<columns {
                let x = Double(column)
                let noise = random(column, row)              // decide el brillo del cuadrito y si destella
                let timing = random(column + 500, row + 900)  // otro número, independiente: decide CUÁNDO destella

                // 1. Franjas: dos ondas que se mueven en diagonal, redondeadas a 4 tonos.
                let wave1: Double = sin(x * 0.16 + y * 0.035 - shift1)
                let wave2: Double = sin(x * 0.07 - y * 0.02 + shift2)
                let wave: Double = 0.5 + 0.25 * wave1 + 0.25 * wave2       // queda entre 0 y 1
                let bandIndex = min(max(Int(wave * 4), 0), 3)               // 0, 1, 2 o 3
                let band = Double(bandIndex) / 3

                // 2. Cada cuadrito "respira" a su propio ritmo; el 6 % de ellos destella.
                //    El ritmo usa `timing` y no `noise`: si usara `noise`, todos los que destellan
                //    (noise > 0.94) tendrían casi el mismo ritmo y prenderían a la vez.
                let breath: Double = 0.5 + 0.5 * sin(time * (0.8 + timing * 1.4) + timing * 40)
                let spark: Double = noise > 0.94 ? pow(breath, 6) : 0

                // 3. Opacidad: base tenue + franja + respiración + destello.
                let baseGlow: Double = 0.07 + 0.17 * band * (0.65 + 0.35 * noise)
                let opacity: Double = min((baseGlow + 0.08 * breath * noise + 0.45 * spark) * brightness, 1) * fade

                // 4. Se redondean la opacidad y el destello a sus niveles para elegir la cubeta.
                let opacityLevel = Int((opacity * Double(opacityLevels - 1)).rounded())
                if opacityLevel <= 0 { continue }                           // invisible: no se dibuja
                let sparkLevel = Int((spark * Double(sparkLevels - 1)).rounded())
                let bucket = (bandIndex * sparkLevels + sparkLevel) * opacityLevels + opacityLevel

                // 5. Cada cuadrito deja 1 punto de separación: eso dibuja la rejilla.
                paths[bucket].addRect(CGRect(x: x * cell + 0.5, y: y * cell + 0.5, width: cell - 1, height: cell - 1))
                used[bucket] = true
            }
        }

        for bucket in 0..<bucketCount where used[bucket] {
            let color = palette[bucket / opacityLevels]
            let opacity = Double(bucket % opacityLevels) / Double(opacityLevels - 1)
            context.fill(paths[bucket], with: .color(color.opacity(opacity)))
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

#Preview("Desvanecido abajo") {
    ZStack {
        Color.black.ignoresSafeArea()
        PixelMosaicView(darkColor: .indigo, lightColor: .purple, sparkleColor: .white, verticalFade: 0.3...0.7)
    }
}
