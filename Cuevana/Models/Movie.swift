//
//  Pelicula.swift
//  Cuevana
//
//  Created by Fernando Miranda on 27/09/26.
//

import Foundation

struct Movie: Identifiable, Hashable {
    let id : UUID
    var title: String
    var year: Int
    var duration: Int
    var gender: String
    var qualification: Double
    var premiereDate: String
    var sinopsis: String
    
    //El init permite pasar un ID específico o generar uno si no se proporciona
    init(id: UUID = UUID(), title: String, year: Int, duration: Int, gender: String, qualification: Double, premiereDate: String, sinopsis: String) {
            self.id = id
            self.title = title
            self.year = year
            self.duration = duration
            self.gender = gender
            self.qualification = qualification
            self.premiereDate = premiereDate
            self.sinopsis = sinopsis
        }
}

let ExampleMovies = [
    Movie(
        //Agregamos los id's manualmente para que se mantengan
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
        title: "Dune: Parte Dos",
        year: 2024,
        duration: 166,
        gender: "Sci-Fi",
        qualification: 8.6,
        premiereDate: "01/03/2024",
        sinopsis: "Paul Atreides se une a Chani y a los Fremen mientras busca venganza contra los conspiradores que destruyeron a su familia."
    ),
    Movie(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
        title: "Oppenheimer",
        year: 2023,
        duration: 180,
        gender: "Drama",
        qualification: 8.9,
        premiereDate: "20/07/2023",
        sinopsis: "La historia del fisico J. Robert Oppenheimer y su papel en el desarrollo de la bomba atomica."
    ),
    Movie(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID(),
        title: "Spider-Man: Across the Spider-Verse",
        year: 2023,
        duration: 140,
        gender: "Animacion",
        qualification: 8.7,
        premiereDate: "02/06/2023",
        sinopsis: "Miles Morales regresa para una nueva aventura a traves del multiverso junto a Gwen Stacy."
    ),
    Movie(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID(),
        title: "The Batman",
        year: 2022,
        duration: 176,
        gender: "Accion",
        qualification: 7.8,
        premiereDate: "04/03/2022",
        sinopsis: "Batman investiga una serie de crimenes en Ciudad Gotica que lo llevan a descubrir la corrupcion."
    ),
    Movie(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005") ?? UUID(),
        title: "El increíble castillo vagabundo",
        year: 2004,
        duration: 119,
        gender: "Animacion japonesa",
        qualification: 8.2,
        premiereDate: "20/11/2004",
        sinopsis: "Sophie es transformada en una anciana por una bruja celosa. Para romper la maldición, encuentra refugio en el castillo ambulante de Howl, un extravagante mago con quien se verá envuelta en una guerra mágica"
    )
]
