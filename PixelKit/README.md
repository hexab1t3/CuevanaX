# PixelKit

Librería del equipo de CuevanaX con un fondo animado estilo pixel. Viene dentro del
repositorio, así que Xcode la compila junto con la app sin instalar nada.

## Qué incluye

| Pieza             | Para qué sirve                                                       |
|-------------------|----------------------------------------------------------------------|
| `PixelMosaicView` | Fondo animado: cuadrícula con franjas y destellos, de los colores que elijas |

## Uso

```swift
import PixelKit

PixelMosaicView(
    darkColor: .indigo,     // franjas oscuras
    lightColor: .cyan,      // franjas claras
    sparkleColor: .white,   // destellos
    cell: 10,               // opcional, tamaño del cuadrito en puntos
    speed: 0.5,             // opcional, velocidad
    brightness: 0.8,        // opcional, brillo
    framesPerSecond: 15,    // opcional, cuántas veces por segundo se redibuja
    verticalFade: 0.2...0.6 // opcional, aparece de forma gradual de arriba hacia abajo
)
```

## Cómo funciona

1. `TimelineView` da la hora actual `framesPerSecond` veces por segundo (15 por defecto;
   el movimiento es lento, así que no hace falta más).
2. `Canvas` divide la pantalla en cuadritos de `cell` puntos.
3. Para cada cuadrito se suman dos ondas (senos) que se mueven con el tiempo;
   el resultado se redondea a 4 tonos entre `darkColor` y `lightColor`: esas son las franjas.
4. Cada cuadrito tiene un número fijo entre 0 y 1 (`random`) que le da su propio
   ritmo de brillo; los que pasan de 0.94 destellan con `sparkleColor`.
5. Se deja 1 punto entre cuadritos, y eso dibuja la rejilla.

## Rendimiento

- Los cuadritos del mismo color y opacidad se juntan en un solo `Path`: cada cuadro hace
  unas decenas de `fill` en vez de uno por cuadrito (en un iPhone son unos 3,600).
- Los colores de franjas y destellos se mezclan una sola vez, al crear la vista.
- La animación se pausa sola cuando la vista no está en pantalla (otra pestaña, una
  pantalla encima), cuando la app no está activa y cuando el usuario activa
  "Reducir movimiento" en Ajustes.
- Para desvanecer el mosaico usa `verticalFade` en vez de `.mask` o `.blur`: esos
  modificadores crean una capa extra en cada cuadro de la animación.
