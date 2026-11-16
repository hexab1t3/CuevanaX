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
    brightness: 0.8         // opcional, brillo
)
```

## Cómo funciona

1. `TimelineView` redibuja unas 30 veces por segundo y da la hora actual.
2. `Canvas` divide la pantalla en cuadritos de `cell` puntos.
3. Para cada cuadrito se suman dos ondas (senos) que se mueven con el tiempo;
   el resultado se redondea a 4 tonos entre `darkColor` y `lightColor`: esas son las franjas.
4. Cada cuadrito tiene un número fijo entre 0 y 1 (`random`) que le da su propio
   ritmo de brillo; los que pasan de 0.94 destellan con `sparkleColor`.
5. Se deja 1 punto entre cuadritos, y eso dibuja la rejilla.

Si el usuario activa "Reducir movimiento" en Ajustes, la animación se pausa.
