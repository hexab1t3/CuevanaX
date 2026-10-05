# CuevanaX — Navegación y estado (MVP)

Define cómo se conectan las pantallas y dónde vive cada dato antes de implementar TMDB y la persistencia de favoritos.

## 1. Mapa de navegación

```
App
├── Sin sesión ──► Login
│                    └─ "Iniciar sesión" ─► (sesión activa)
└── Con sesión ──► TabView
                    ├── Películas ──► Detalle de película
                    ├── Buscar    ──► Detalle de película (opcional)
                    ├── Favoritos ──► Detalle de película (opcional)
                    └── Perfil ──► "Cerrar sesión" ─► Login
```

| Pantalla | Se llega desde | Va hacia |
|---|---|---|
| Login | Arranque sin sesión, Cerrar sesión | TabView (Películas) |
| Películas | Pestaña / tras login | Detalle |
| Detalle | Película tocada en Películas | Regresa a Películas |
| Buscar | Pestaña | (MVP) ninguna |
| Favoritos | Pestaña | (MVP) ninguna |
| Perfil | Pestaña | Login |

Alcance del MVP: el detalle se abre únicamente desde Películas. Abrirlo desde Buscar y Favoritos queda como mejora, y la estructura propuesta lo permite sin rediseñar.

## 2. Información por pantalla

### Login
- **Muestra:** logo, título, campos de correo y contraseña, botón "Iniciar sesión".
- **Recibe:** el estado global de sesión (binding).
- **Modifica:** el estado de sesión (a "autenticado").
- **Conserva:** nada. Correo y contraseña son temporales y se descartan al entrar; la contraseña nunca se guarda.

### Películas
- **Muestra:** lista de películas en cartelera (póster, título, calificación).
- **Recibe:** catálogo desde TMDB (vía el servicio/modelo de películas).
- **Modifica:** la película seleccionada, para abrir el detalle.
- **Conserva:** la lista cargada y la posición de scroll al volver desde el detalle.

### Detalle de película
- **Muestra:** póster, título, año, género, duración, calificación, sinopsis y botón de favorito.
- **Recibe:** la película seleccionada (dato inmutable) y el acceso al estado de favoritos.
- **Modifica:** si la película es favorita (agregar/quitar).
- **Conserva:** nada propio; el estado de favorito se guarda en el almacén de favoritos, no en la vista.

### Buscar
- **Muestra:** campo de texto, estado vacío o resultados.
- **Recibe:** resultados de búsqueda de TMDB.
- **Modifica:** el texto de búsqueda.
- **Conserva:** el texto y los resultados mientras se cambia de pestaña.

### Favoritos
- **Muestra:** películas marcadas como favoritas o un estado vacío.
- **Recibe:** el almacén de favoritos (solo lectura, más la acción de quitar).
- **Modifica:** quita favoritos.
- **Conserva:** persiste entre ejecuciones de la app.

### Perfil
- **Muestra:** nombre y correo del usuario, botón "Cerrar sesión".
- **Recibe:** datos del usuario y estado de sesión.
- **Modifica:** el estado de sesión (a "no autenticado").
- **Conserva:** nada propio.

## 3. Organización del estado

Regla general: el estado vive en el nivel más bajo que necesitan todas las vistas que lo usan, y existe una sola fuente de verdad por dato.

| Dato | Dónde vive | Mecanismo | Por qué |
|---|---|---|---|
| Correo y contraseña (campos) | `LoginView` | `@State` | Solo los usa esa vista y son temporales. |
| Sesión iniciada (sí/no) | Raíz de la app (`CuevanaApp`) | `@State` + `@Binding` hacia Login, Tabs y Perfil | Decide qué árbol se muestra; Login lo activa y Perfil lo desactiva. |
| Película seleccionada | `PeliculasView` | `@State` | Es estado de navegación local de esa pantalla. |
| Texto de búsqueda | `BuscarView` | `@State` | Solo lo usa esa vista. |
| Resultados de búsqueda | Modelo de búsqueda | `@Observable` | Se llenan de forma asíncrona y deben sobrevivir al cambio de pestaña. |
| Catálogo de películas (TMDB) | Modelo de películas | `@Observable` | Estado de carga/error/datos compartido entre vistas. |
| Película mostrada en detalle | Parámetro de `DetallePeliculaView` | `let` | Dato de solo lectura entregado por la vista padre. |
| Almacén de favoritos | Un solo objeto compartido | `@Observable` inyectado con `@Environment` | Lo leen y modifican Detalle, Favoritos y las filas de la lista; evita pasarlo por cada vista intermedia. |
| Favoritos persistidos | Disco | `UserDefaults` | Son pocos datos simples (ids de películas) y el requisito es guardarlos localmente. |
| Cierre del detalle | Entorno de SwiftUI | `@Environment(\.dismiss)` | Acción nativa del entorno, no un dato propio. |

### Decisiones clave
- **Favoritos: una sola fuente.** Se guarda un conjunto de ids en `UserDefaults`; el almacén `@Observable` lo carga al iniciar y lo escribe en cada cambio. Las vistas solo lo consultan, así que no hay copias que se desincronicen.
- **Sin estado global mutable.** Hoy el arreglo de películas de ejemplo es una variable global que el detalle modifica. En el diseño final los datos vienen de TMDB (inmutables) y la marca de favorito deja de ser un campo de la película.
- **`@Binding` solo para la sesión.** Es el único dato que sube y baja por varias capas con escritura bidireccional; todo lo demás se resuelve con `@Environment` o parámetros.
- **Qué se guarda y qué no.** Se persisten los favoritos. No se persisten contraseña, resultados de búsqueda ni el catálogo (se vuelven a pedir).
- **Sesión:** en el MVP vive solo en memoria. Si más adelante debe sobrevivir al cierre de la app, el token iría en Keychain, no en `UserDefaults`.

## 4. Estrategia de navegación

| Nivel | Mecanismo | Uso |
|---|---|---|
| Sesión | Condicional en la raíz (`if sesión`) | Cambia entre Login y la app principal sin pila de navegación: no se debe poder volver al login con "atrás". |
| Secciones | `TabView` | Cuatro pestañas de mismo nivel, cada una conserva su propio estado al cambiar. |
| Películas → Detalle | `NavigationStack` dentro de la pestaña + `NavigationLink(value:)` y `navigationDestination` | Navegación jerárquica con botón "atrás" y gesto de deslizar. Recomendado para el detalle. |
| Detalle (alternativa) | `.sheet(item:)` | Presenta el detalle de forma modal con "Cerrar". Es lo que se usa hoy en la entrega de interfaces. |
| Confirmaciones | `.alert` / `.confirmationDialog` | Por ejemplo, confirmar el cierre de sesión (opcional). |

### Recomendación
Usar `NavigationStack` para Películas → Detalle: el detalle es un nivel más profundo del mismo contenido, no una tarea aparte, y así se reutiliza al abrirlo desde Buscar y Favoritos. Cada pestaña tendría su propio `NavigationStack`, de modo que cambiar de pestaña no pierde la posición. `sheet` queda como alternativa válida si se prefiere una presentación modal, y es la opción actual de la interfaz.

### Flujo del usuario
1. Abre la app → Login.
2. Inicia sesión → aparece el `TabView` en Películas.
3. Toca una película → Detalle (push o modal).
4. Marca favorito → se actualiza el almacén y se persiste.
5. Cambia a Favoritos → ve la película guardada.
6. Cambia a Perfil → cierra sesión → vuelve a Login.
