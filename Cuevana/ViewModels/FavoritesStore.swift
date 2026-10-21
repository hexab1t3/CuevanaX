import Foundation
import Observation

@Observable
class FavoritesStore {
    private(set) var ids: Set<String>
    private let key = "favorites"

    init() {
        let saved = UserDefaults.standard.array(forKey: key) as? [String] ?? []
        ids = Set(saved)
    }

    func isFavorite(_ movie: Movie) -> Bool {
        let idString = movie.id.uuidString
        return ids.contains(idString)
    }

    func alternate(_ movie: Movie) {
        let idString = movie.id.uuidString
        if ids.contains(idString) {
            ids.remove(idString)
        } else {
            ids.insert(idString)
        }
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
    
    func favoriteMovies(from allMovies: [Movie]) -> [Movie] {
        allMovies.filter { isFavorite($0) }
    }
    
    
}
