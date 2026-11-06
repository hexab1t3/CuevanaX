//
//  FavoriteMovie.swift
//  Cuevana
//

import Foundation
import SwiftData

// Modelo para guardar las películas favoritas con SwiftData
@Model
final class FavoriteMovie {
    // Clave única para evitar duplicados
    @Attribute(.unique) var id: String
    var tmdbId: Int?
    var title: String
    var year: Int
    var duration: Int
    var gender: String
    var qualification: Double
    var premiereDate: String
    var sinopsis: String
    var posterPath: String?
    var savedAt: Date

    init(
        id: String,
        tmdbId: Int? = nil,
        title: String,
        year: Int,
        duration: Int,
        gender: String,
        qualification: Double,
        premiereDate: String,
        sinopsis: String,
        posterPath: String? = nil,
        savedAt: Date = Date()
    ) {
        self.id = id
        self.tmdbId = tmdbId
        self.title = title
        self.year = year
        self.duration = duration
        self.gender = gender
        self.qualification = qualification
        self.premiereDate = premiereDate
        self.sinopsis = sinopsis
        self.posterPath = posterPath
        self.savedAt = savedAt
    }

    // Inicializador conveniente desde Movie
    convenience init(from movie: Movie) {
        let identifier = movie.tmdbId != nil ? String(movie.tmdbId!) : movie.id.uuidString
        self.init(
            id: identifier,
            tmdbId: movie.tmdbId,
            title: movie.title,
            year: movie.year,
            duration: movie.duration,
            gender: movie.gender,
            qualification: movie.qualification,
            premiereDate: movie.premiereDate,
            sinopsis: movie.sinopsis,
            posterPath: movie.posterPath
        )
    }

    // Convierte a Movie para las vistas
    func toMovie() -> Movie {
        let uuid = UUID(uuidString: id) ?? UUID()
        return Movie(
            id: uuid,
            title: title,
            year: year,
            duration: duration,
            gender: gender,
            qualification: qualification,
            premiereDate: premiereDate,
            sinopsis: sinopsis,
            tmdbId: tmdbId,
            posterPath: posterPath
        )
    }
}
