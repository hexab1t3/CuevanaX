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

## Frames y accesibilidad

Debajo de cada frame se listan las etiquetas de accesibilidad (VoiceOver) que la app le dice a las personas con discapacidad visual en cada pantalla, en orden.

<!-- Grupo de Imágenes 1 -->
<table>
  <tr>
    <td colspan="3" align="center">
      <img src="https://github.com/user-attachments/assets/28d000ec-fc34-49a0-99da-599b27af5203" width="100%" />
    </td>
  </tr>
  <tr>
    <td valign="top" width="33%">
      <h4>Vista Login</h4>
      <ul>
        <li>Entra a la app</li>
        <li>Le dice el título de la app</li>
        <li>Le dice ingresa Correo</li>
        <li>Le dice ingresa Contraseña</li>
        <li>Dice iniciar sesión (Botón)</li>
        <li>Si no tienes cuenta regístrate</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 2]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 3]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
  </tr>
</table>

<!-- Grupo de Imágenes 2 -->
<table>
  <tr>
    <td colspan="3" align="center">
      <img src="https://github.com/user-attachments/assets/e81c5f39-8edc-4598-b6a2-b0689fe5ed2e" width="100%" />
    </td>
  </tr>
  <tr>
    <td valign="top" width="33%">
      <h4>[Pantalla 1]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 2]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 3]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
  </tr>
</table>

<!-- Grupo de Imágenes 3 -->
<table>
  <tr>
    <td colspan="3" align="center">
      <img src="https://github.com/user-attachments/assets/215b0cc0-4fe6-4ec8-9744-90c9d1f9de45" width="100%" />
    </td>
  </tr>
  <tr>
    <td valign="top" width="33%">
      <h4>[Pantalla 1]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 2]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 3]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
  </tr>
</table>

<!-- Grupo de Imágenes 4 -->
<table>
  <tr>
    <td colspan="3" align="center">
      <img src="https://github.com/user-attachments/assets/fa01c784-1abb-4601-af8e-22a242ca2867" width="100%" />
    </td>
  </tr>
  <tr>
    <td valign="top" width="33%">
      <h4>[Pantalla 1]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 2]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 3]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
  </tr>
</table>

<!-- Grupo de Imágenes 5 -->
<table>
  <tr>
    <td colspan="3" align="center">
      <img src="https://github.com/user-attachments/assets/b4365df4-c838-4f55-83e3-3168992ea51e" width="100%" />
    </td>
  </tr>
  <tr>
    <td valign="top" width="33%">
      <h4>[Pantalla 1]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 2]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>[Pantalla 3]</h4>
      <ul>
        <li>[Punto 1]</li>
        <li>[Punto 2]</li>
      </ul>
    </td>
  </tr>
</table>
