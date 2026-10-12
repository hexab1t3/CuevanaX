# Investigación MVVM y arquitectura

## Por qué separar responsabilidades

Separar responsabilidades significa que cada parte del código se encarga de una sola cosa. Así es más fácil entender el proyecto, encontrar errores, hacer cambios sin romper otras partes, reutilizar código y probar la lógica sin tener que abrir la interfaz. También permite que varias personas trabajen al mismo tiempo en partes distintas sin pisarse.

## Interfaz, datos y lógica

- Interfaz: lo que el usuario ve y toca. Textos, listas, botones, colores y la navegación entre pantallas. No debería decidir reglas, solo mostrar.
- Datos: la información que maneja la app y cómo se guarda u obtiene. Por ejemplo las películas, los ids de favoritos en UserDefaults o la respuesta de la API de TMDB.
- Lógica: las reglas y decisiones. Por ejemplo filtrar películas por texto, decidir si una película es favorita, agregarla o quitarla, validar un correo o decidir qué hacer si falla la carga.

## Problemas cuando una View hace demasiado

- El archivo crece mucho y es difícil de leer.
- La misma lógica se copia en varias vistas (por ejemplo el filtro de búsqueda o el cálculo de favoritas) y luego se desincroniza.
- No se puede probar la lógica sin levantar la interfaz.
- Cualquier cambio visual puede romper la lógica y al revés.
- Es difícil cambiar la fuente de datos, por ejemplo pasar de datos de ejemplo a TMDB, porque está mezclada con la vista.
- Se vuelve más fácil tener varias fuentes de verdad para el mismo dato.

## Model

Es la representación de los datos y sus reglas básicas. No sabe nada de la interfaz. En SwiftUI normalmente son structs o clases simples, y también los servicios que obtienen o guardan esos datos (API, UserDefaults, base de datos).

## View

Es la interfaz. En SwiftUI es un struct que conforma View y describe cómo se ve la pantalla según el estado que recibe. Debe ser lo más "tonta" posible: muestra datos y avisa cuando el usuario hace algo, pero no decide reglas de negocio.

## ViewModel

Es el intermediario entre la View y el Model. Prepara los datos para que la vista solo tenga que mostrarlos, guarda el estado de la pantalla (cargando, error, resultados, texto de búsqueda) y expone funciones para las acciones del usuario. En SwiftUI moderno se hace con una clase marcada con @Observable, así la vista se actualiza sola cuando cambia algo.

## Cómo fluye la información

1. El usuario hace algo en la View (escribe, toca un botón).
2. La View llama a una función del ViewModel.
3. El ViewModel aplica la lógica y, si hace falta, pide o actualiza datos en el Model o en un servicio.
4. El Model devuelve los datos.
5. El ViewModel actualiza su estado.
6. Como el ViewModel es @Observable, la View se vuelve a dibujar con el estado nuevo.

La View nunca habla directo con el servicio de datos, siempre pasa por el ViewModel. El flujo es: View -> ViewModel -> Model, y de regreso Model -> ViewModel -> View.

## Responsabilidades que se pueden separar en CuevanaX

Revisando el código actual:

- PeliculasView, BuscarView y FavoritosView usan directamente el arreglo global peliculasEjemplo. Esa lista debería venir de un servicio (hoy datos de ejemplo, después TMDB).
- BuscarView hace el filtro de búsqueda dentro del body. Esa lógica puede vivir en un ViewModel.
- FavoritosView calcula qué películas son favoritas cruzando el catálogo con los ids. Eso también puede salir de la vista.
- FavoritosStore ya está separado de las vistas y es la única fuente de verdad de favoritos, así que ya funciona como una pieza del modelo compartido.
- LoginView solo cambia estaAutenticado a true. La validación del correo y contraseña y la llamada para iniciar sesión deberían estar fuera de la vista.
- PerfilView tiene el nombre y correo escritos en el código. Deberían venir de un modelo de usuario o de la sesión.
- El estado de sesión vive en CuevanaApp como un Bool y se pasa con @Binding. Podría moverse a un objeto de sesión observable.
- Falta manejar estados de carga y error para cuando se conecte TMDB.
- Item.swift y el ModelContainer de SwiftData son restos de la plantilla y no se usan.

## Propuesta inicial de organización con MVVM

Estructura de carpetas:

    Cuevana/
      Models/
        Pelicula.swift
        Usuario.swift
      Services/
        PeliculasService.swift      (datos de ejemplo ahora, TMDB después)
        FavoritosStore.swift        (UserDefaults)
        SesionStore.swift
      ViewModels/
        LoginViewModel.swift
        PeliculasViewModel.swift
        BuscarViewModel.swift
        FavoritosViewModel.swift
        DetallePeliculaViewModel.swift   (opcional)
        PerfilViewModel.swift
      Views/
        LoginView.swift
        MainTabView.swift
        PeliculasView.swift
        BuscarView.swift
        FavoritosView.swift
        DetallePeliculaView.swift
        PerfilView.swift
      CuevanaApp.swift

### Qué corresponde al Model

- Pelicula: id de TMDB, título, año, duración, género, calificación, fecha de estreno, sinopsis y después la URL del póster.
- Usuario: nombre y correo.
- PeliculasService: obtiene la cartelera y busca películas. Primero con datos de ejemplo y luego con la API de TMDB.
- FavoritosStore: guarda y carga los ids de favoritos en UserDefaults. Es la única fuente de verdad de favoritos.
- SesionStore: guarda si hay sesión iniciada y el usuario actual.

### Qué corresponde a las View

- LoginView, MainTabView, PeliculasView, BuscarView, FavoritosView, DetallePeliculaView y PerfilView.
- Se encargan solo de dibujar, de la navegación (NavigationStack, NavigationLink, navigationDestination, TabView) y de mandar las acciones del usuario al ViewModel.

### Qué responsabilidades pueden vivir fuera de las View

- Obtener la lista de películas.
- Filtrar las películas por texto.
- Calcular la lista de favoritas a partir de los ids.
- Agregar y quitar favoritos y guardarlos.
- Validar el login e iniciar o cerrar sesión.
- Manejar los estados de cargando, error y vacío.
- Dar formato a datos como la calificación o la fecha.

### ViewModels necesarios y sus responsabilidades

- LoginViewModel: guarda correo y contraseña, valida que no estén vacíos y que el correo tenga formato correcto, llama a SesionStore para iniciar sesión y expone un mensaje de error si algo falla.
- PeliculasViewModel: pide la cartelera a PeliculasService, guarda la lista y el estado (cargando, cargado, error) para que la vista solo lo muestre.
- BuscarViewModel: guarda el texto de búsqueda y expone los resultados filtrados. Más adelante hará la búsqueda contra TMDB.
- FavoritosViewModel: usa FavoritosStore y el catálogo para exponer la lista de películas favoritas y permitir quitarlas.
- DetallePeliculaViewModel (opcional): recibe la película, dice si es favorita y alterna el favorito usando FavoritosStore. Como hoy el detalle es simple, se puede quedar usando FavoritosStore directo.
- PerfilViewModel: expone el nombre, correo y número de favoritas, y llama a SesionStore para cerrar sesión.

FavoritosStore y SesionStore se crean una sola vez en CuevanaApp y se comparten con @Environment, igual que ahora con favoritos, para que no haya datos duplicados entre pantallas.
