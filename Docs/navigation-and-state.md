# CuevanaX — Navegación y estado (MVP)

Define cómo se conectan las pantallas y dónde vive cada dato. La navegación y el almacén de favoritos descritos aquí ya están implementados; los datos de TMDB siguen pendientes y hoy se usan películas de ejemplo.

## 1. Mapa de navegación

```
App
├── Sin sesión ──► Login
│                    └─ "Iniciar sesión" ─► (sesión activa)
└── Con sesión ──► TabView
                    ├── Películas ──► Detalle de película
                    ├── Buscar    ──► Detalle de película
                    ├── Favoritos ──► Detalle de película
                    └── Perfil ──► "Cerrar sesión" ─► Login
```

| Pantalla | Se llega desde | Va hacia |
|---|---|---|
| Login | Arranque sin sesión, Cerrar sesión | TabView (Películas) |
| Películas | Pestaña / tras login | Detalle |
| Buscar | Pestaña | Detalle |
| Favoritos | Pestaña | Detalle |
| Detalle | Película tocada en Películas, Buscar o Favoritos | Regresa a la pantalla de origen |
| Perfil | Pestaña | Login |

Cada pestaña tiene su propia pila de navegación, así que el detalle abierto desde una pestaña no afecta a las demás y al cambiar de pestaña se conserva la posición.

## 2. Información por pantalla

### Login
- **Muestra:** logo, título, campos de correo y contraseña, botón "Iniciar sesión".
- **Recibe:** el estado global de sesión (binding).
- **Modifica:** el estado de sesión (a "autenticado").
- **Conserva:** nada. Correo y contraseña son temporales y se descartan al entrar; la contraseña nunca se guarda.

### Películas
- **Muestra:** lista de películas en cartelera (póster, título, calificación).
- **Recibe:** catálogo de películas (TMDB; hoy, datos de ejemplo).
- **Modifica:** la pila de navegación, al tocar una película.
- **Conserva:** la lista cargada y la posición de scroll al volver desde el detalle.

### Buscar
- **Muestra:** campo de texto, estado vacío o lista de resultados.
- **Recibe:** el catálogo contra el que se filtra (TMDB; hoy, datos de ejemplo).
- **Modifica:** el texto de búsqueda y la pila de navegación, al tocar un resultado.
- **Conserva:** el texto y los resultados mientras se cambia de pestaña o se abre un detalle.

### Favoritos
- **Muestra:** películas marcadas como favoritas o un estado vacío.
- **Recibe:** el almacén de favoritos.
- **Modifica:** la pila de navegación, al tocar una película.
- **Conserva:** persiste entre ejecuciones de la app; la lista se actualiza sola cuando cambia un favorito.

### Detalle de película
- **Muestra:** póster, título, año, género, sinopsis y botón de favorito.
- **Recibe:** la película seleccionada (dato inmutable) y el almacén de favoritos.
- **Modifica:** si la película es favorita (agregar/quitar).
- **Conserva:** nada propio; el estado de favorito vive en el almacén, no en la vista.

### Perfil
- **Muestra:** nombre y correo del usuario, botón "Cerrar sesión".
- **Recibe:** el estado de sesión.
- **Modifica:** el estado de sesión (a "no autenticado").
- **Conserva:** nada propio.

## 3. Organización del estado

Regla general: el estado vive en el nivel más bajo que necesitan todas las vistas que lo usan, y existe una sola fuente de verdad por dato.

| Dato | Dónde vive | Mecanismo | Por qué |
|---|---|---|---|
| Correo y contraseña (campos) | `LoginView` | `@State` | Solo los usa esa vista y son temporales. |
| Sesión iniciada (sí/no) | Raíz de la app (`CuevanaApp`) | `@State` + `@Binding` hacia Login, Tabs y Perfil | Decide qué árbol se muestra; Login lo activa y Perfil lo desactiva. |
| Pila de navegación | Cada `NavigationStack` | Interno de SwiftUI | Con `NavigationLink(value:)` y `navigationDestination` no hace falta guardar la película seleccionada. |
| Texto de búsqueda | `BuscarView` | `@State` | Solo lo usa esa vista. |
| Película mostrada en detalle | Parámetro de `DetallePeliculaView` | `let` | Dato de solo lectura entregado por la vista que navega. |
| Almacén de favoritos | `FavoritosStore`, creado en `CuevanaApp` | `@Observable` inyectado con `@Environment` | Lo leen y modifican Detalle y Favoritos; evita pasarlo por cada vista intermedia y refresca las vistas al cambiar. |
| Favoritos persistidos | Disco | `UserDefaults` | Son pocos datos simples (ids de películas) y el requisito es guardarlos localmente. |

### Decisiones clave
- **Favoritos: una sola fuente.** `FavoritosStore` guarda un conjunto de ids en `UserDefaults`: lo carga al iniciar y lo escribe en cada cambio. Las vistas solo lo consultan, así que no hay copias que se desincronicen.
- **Ids estables.** `Pelicula` usa como `id` el identificador de TMDB (un entero), no un `UUID` generado en cada ejecución, porque de otro modo los favoritos guardados no coincidirían al reabrir la app.
- **`Pelicula` es `Hashable`** para poder usarla como valor de `NavigationLink(value:)`.
- **Sin estado global mutable.** La marca de favorito ya no es un campo de la película ni se modifica un arreglo global.
- **`@Binding` solo para la sesión.** Es el único dato que sube y baja por varias capas con escritura bidireccional; todo lo demás se resuelve con `@Environment` o parámetros.
- **Qué se guarda y qué no.** Se persisten los favoritos. No se persisten contraseña ni resultados de búsqueda.
- **Sesión:** en el MVP vive solo en memoria. Si más adelante debe sobrevivir al cierre de la app, el token iría en Keychain, no en `UserDefaults`.

## 4. Estrategia de navegación

| Nivel | Mecanismo | Uso |
|---|---|---|
| Sesión | Condicional en la raíz (`if estaAutenticado`) | Cambia entre Login y la app principal sin pila de navegación: no se debe poder volver al login con "atrás". |
| Secciones | `TabView` | Cuatro pestañas del mismo nivel, cada una conserva su propio estado al cambiar. |
| Detalle | `NavigationStack` en cada pestaña, `NavigationLink(value:)` en las filas y `navigationDestination(for:)` para construir el detalle | Navegación jerárquica con botón "atrás" y gesto de deslizar. Aplica en Películas, Buscar y Favoritos. |

### Por qué `NavigationStack` y no `sheet`
El detalle es un nivel más profundo del mismo contenido, no una tarea aparte, así que se presenta con navegación jerárquica. Con eso se reutiliza el mismo detalle desde las tres pestañas y el botón "atrás" lo maneja el sistema, sin botón "Cerrar" propio. En el MVP no queda ninguna pantalla que requiera `sheet`.

### Flujo del usuario
1. Abre la app → Login.
2. Inicia sesión → aparece el `TabView` en Películas.
3. Toca una película → Detalle.
4. Marca favorito → se actualiza el almacén y se persiste.
5. Cambia a Favoritos → ve la película guardada; al tocarla abre su detalle.
6. En Buscar, toca un resultado → abre su detalle.
7. Cambia a Perfil → cierra sesión → vuelve a Login.
