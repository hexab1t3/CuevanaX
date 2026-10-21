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
      <h4>Vista Películas</h4>
      <ul>
        <li>Entra a la pestaña Películas</li>
        <li>Le dice el título Películas</li>
        <li>Le dice el nombre de la película, el año y la calificación</li>
        <li>Dice que se puede abrir el detalle (Botón)</li>
        <li>Le dice el menú inferior de 4 opciones: Películas, Buscar, Favoritos y Perfil</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>Vista Perfil</h4>
      <ul>
        <li>Le dice el título Mi Perfil</li>
        <li>Le dice el nombre y el correo del usuario</li>
        <li>Le dice que la sesión está activa</li>
        <li>Le dice cuántas favoritas y vistas tiene y su género preferido</li>
        <li>Dice cerrar sesión (Botón)</li>
        <li>Le dice que está en la pestaña Perfil</li>
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
      <h4>Vista Cargando</h4>
      <ul>
        <li>Le dice el título Películas</li>
        <li>Le dice que se está cargando la cartelera</li>
        <li>Le dice que espere mientras se obtienen las películas</li>
        <li>Le dice que está en la pestaña Películas</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>Vista Cartelera</h4>
      <ul>
        <li>Le dice el título Películas</li>
        <li>Le dice la sección En cartelera</li>
        <li>Le dice el nombre de la película, el año, el género y la calificación</li>
        <li>Dice que se puede abrir el detalle (Botón)</li>
        <li>Le dice la sección Populares hoy y sus películas</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>Vista Detalle</h4>
      <ul>
        <li>Dice regresar a Películas (Botón)</li>
        <li>Le dice el póster de la película</li>
        <li>Le dice el título y el año</li>
        <li>Le dice la calificación, la duración y el género</li>
        <li>Le dice la fecha de estreno</li>
        <li>Le lee la sinopsis</li>
        <li>Dice agregar a favoritos (Botón)</li>
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
      <h4>Vista Buscador</h4>
      <ul>
        <li>Le dice el título Buscar</li>
        <li>Le dice ¿Qué película buscas? (Campo de texto)</li>
        <li>Le dice Explora el catálogo</li>
        <li>Le dice que escriba el título de una película para buscar</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>Vista Resultados</h4>
      <ul>
        <li>Le dice el título Buscar</li>
        <li>Le dice el texto escrito en el campo de búsqueda</li>
        <li>Le dice el nombre de cada resultado, el año, la calificación y el género</li>
        <li>Dice que se puede abrir el detalle (Botón)</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>Vista Sin resultados</h4>
      <ul>
        <li>Le dice el título Buscar</li>
        <li>Le dice el texto escrito en el campo de búsqueda</li>
        <li>Le dice Sin resultados</li>
        <li>Le dice que no se encontraron coincidencias para ese texto</li>
        <li>Le dice que revise la ortografía o busque otro título</li>
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
      <h4>Vista Favoritos vacíos</h4>
      <ul>
        <li>Le dice el título Favoritos</li>
        <li>Le dice Aún no tienes favoritas</li>
        <li>Le dice que guarde películas tocando el corazón para verlas aquí</li>
        <li>Dice explorar cartelera (Botón)</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>Vista Detalle favorita</h4>
      <ul>
        <li>Dice regresar a Películas (Botón)</li>
        <li>Le dice el título de la película</li>
        <li>Le dice que está guardada en favoritos</li>
        <li>Le lee la sinopsis</li>
        <li>Dice quitar de favoritos (Botón)</li>
      </ul>
    </td>
    <td valign="top" width="33%">
      <h4>Vista Lista de favoritos</h4>
      <ul>
        <li>Le dice el título Favoritos y cuántas películas tiene</li>
        <li>Le dice el nombre de cada película, el año, el género y la calificación</li>
        <li>Le dice que está disponible sin conexión</li>
        <li>Dice que se puede abrir el detalle (Botón)</li>
        <li>Le dice que deslice a la izquierda para eliminar</li>
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
