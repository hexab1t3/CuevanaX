# Documentación técnica — CuevanaX

## 1. Arquitectura

MVVM: las vistas dibujan y mandan acciones a su ViewModel; los ViewModels guardan el estado y llaman a los servicios; los servicios hablan con TMDB o con SwiftData.

| Carpeta / componente | Responsabilidad |
|---|---|
| `CuevanaApp.swift` | Entrada: decide entre Login y la app, crea `FavoritesStore` y configura `URLCache`. |
| `Models/` | `Movie` (modelo de la app) y `FavoriteMovie` (modelo SwiftData). |
| `Services/MovieServices.swift` | Peticiones a TMDB y DTOs de respuesta. |
| `Services/FavoritesStore.swift` | Guarda, quita y consulta favoritos. |
| `Services/AuthService.swift` | Validación del login. |
| `Services/API's Configurations/TMDBConfig.swift` | Host, idioma y lectura del token. |
| `ViewModels/` y `Views/` | Una pantalla por ViewModel: Login, Películas, Detalle, Buscar, Favoritos, Perfil. |
| `PixelKit/` | Paquete local con el fondo mosaico pixel. |
| `CuevanaTests/`, `CuevanaUITests/` | Pruebas unitarias y de interfaz. |

Los ViewModels reciben sus servicios por protocolo (`MovieServiceProtocol`, `AuthServiceProtocol`) para poder probarlos con servicios falsos.

## 2. Networking

API: TMDB v3, host `https://api.themoviedb.org`, header `Authorization: Bearer <token>`, parámetro `language=es-MX`.

| Endpoint | Uso |
|---|---|
| `GET /3/movie/popular?page=` | Pantalla Películas y "Cargar más" |
| `GET /3/search/movie?query=` | Pantalla Buscar |
| `https://image.tmdb.org/t/p/w500` / `w780` | Pósters y fondos |

Modelos de respuesta:

```swift
struct TMDBMovieResponse: Decodable { let results: [TMDBMovieItem] }

struct TMDBMovieItem: Decodable {
    let id: Int
    let title: String
    let overview: String
    let voteAverage: Double
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
}
```

`toMovie()` convierte cada resultado a `Movie`. Los errores (`NetworkError`: token faltante, sin conexión, respuesta inválida, error HTTP, error de decodificación) muestran un mensaje en español con botón de reintentar. El token se busca en la variable de entorno `TMDB_BEARER_TOKEN`, `Info.plist` y `Secrets.plist`.

## 3. Persistencia

Los favoritos se guardan con **SwiftData** (`FavoriteMovie`): id único, título, año, duración, género, calificación, fecha de estreno, sinopsis, póster y fecha de guardado. Solo `FavoritesStore` escribe. No se guarda la contraseña, la sesión ni las búsquedas.

## 4. Decisiones técnicas

- MVVM con `@Observable` para separar la lógica y probarla sin interfaz.
- SwiftData en lugar de UserDefaults para guardar la película completa y verla sin conexión.
- No se hizo un DTO aparte para favoritos porque `FavoritesStore` ya convierte entre `Movie` y `FavoriteMovie`.
- Token fuera del código, en `Secrets.plist` ignorado por git.
- Espera de 300 ms en la búsqueda para no mandar una petición por letra.

## 5. Limitaciones conocidas

- Login simulado: cualquier correo y contraseña no vacíos entran.
- Perfil con datos de ejemplo y sesión solo en memoria.
- Duración (120 min) y género ("Película") genéricos porque los endpoints de lista no los traen.
- Requiere token propio de TMDB.
- Solo iOS 26 o superior (Liquid Glass).
- Favoritos solo en el dispositivo.
