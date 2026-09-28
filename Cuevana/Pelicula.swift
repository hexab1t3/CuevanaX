//
//  Pelicula.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import Foundation

struct Pelicula: Identifiable {
    let id = UUID()
    var titulo: String
    var anio: Int
    var duracion: Int
    var genero: String
    var calificacion: Double
    var fechaEstreno: String
    var sinopsis: String
    var esFavorita: Bool
}

var peliculasEjemplo = [
    Pelicula(
        titulo: "Dune: Parte Dos",
        anio: 2024,
        duracion: 166,
        genero: "Sci-Fi",
        calificacion: 8.6,
        fechaEstreno: "01/03/2024",
        sinopsis: "Paul Atreides se une a Chani y a los Fremen mientras busca venganza contra los conspiradores que destruyeron a su familia.",
        esFavorita: false
    ),
    Pelicula(
        titulo: "Oppenheimer",
        anio: 2023,
        duracion: 180,
        genero: "Drama",
        calificacion: 8.9,
        fechaEstreno: "20/07/2023",
        sinopsis: "La historia del fisico J. Robert Oppenheimer y su papel en el desarrollo de la bomba atomica.",
        esFavorita: false
    ),
    Pelicula(
        titulo: "Spider-Man: Across the Spider-Verse",
        anio: 2023,
        duracion: 140,
        genero: "Animacion",
        calificacion: 8.7,
        fechaEstreno: "02/06/2023",
        sinopsis: "Miles Morales regresa para una nueva aventura a traves del multiverso junto a Gwen Stacy.",
        esFavorita: false
    ),
    Pelicula(
        titulo: "The Batman",
        anio: 2022,
        duracion: 176,
        genero: "Accion",
        calificacion: 7.8,
        fechaEstreno: "04/03/2022",
        sinopsis: "Batman investiga una serie de crimenes en Ciudad Gotica que lo llevan a descubrir la corrupcion.",
        esFavorita: false
    )
]
