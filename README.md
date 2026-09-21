# CuevanaX

# Proyecto Integrador — App de Películas iOS

App de iOS para consultar películas usando la API de TMDB. Proyecto de la materia Desarrollo iOS en FCA UNAM.

## Flujo principal

Al abrir la app lo primero que ve el usuario es la pantalla de login. Ahí ingresa su correo y contraseña para entrar.

Una vez autenticado, la app muestra cuatro secciones accesibles desde el menú de abajo:

1. **Películas** — pantalla principal con las películas en cartelera. Se muestran en una lista con póster, título y calificación. Al tocar una película se abre el detalle con sinopsis, género y más información.
2. **Buscar** — campo de búsqueda para encontrar cualquier película por nombre. Los resultados aparecen en tiempo real mientras el usuario escribe.
3. **Favoritos** — aquí se guardan las películas que el usuario marcó como favoritas desde el detalle. Se pueden quitar en cualquier momento.
4. **Perfil** — muestra el nombre y correo del usuario. Desde aquí se puede cerrar sesión, lo que regresa a la pantalla de login.

## Requisitos

- Xcode 15 o superior
- iOS 16+
- API key de [themoviedb.org](https://www.themoviedb.org/)

## Cómo correrlo

1. Clona el repositorio
2. Abre el proyecto en Xcode
3. Agrega tu API key de TMDB en el archivo de configuración
4. Corre la app en el simulador o en un dispositivo físico

## Alcance

El proyecto incluye:

- Login con correo y contraseña
- Catálogo de películas en cartelera (desde TMDB)
- Búsqueda por nombre
- Guardado de favoritos de forma local
- Perfil con cierre de sesión

No incluye registro de nuevos usuarios ni pagos. Solo lo definido para el proyecto integrador.

## Tecnologías

- Swift / SwiftUI
- TMDB API
- UserDefaults para favoritos

si
