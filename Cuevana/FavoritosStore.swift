import Foundation
import Observation

@Observable
class FavoritosStore {
    private(set) var ids: Set<Int>
    private let llave = "favoritos"

    init() {
        let guardados = UserDefaults.standard.array(forKey: llave) as? [Int] ?? []
        ids = Set(guardados)
    }

    func esFavorita(_ pelicula: Pelicula) -> Bool {
        ids.contains(pelicula.id)
    }

    func alternar(_ pelicula: Pelicula) {
        if ids.contains(pelicula.id) {
            ids.remove(pelicula.id)
        } else {
            ids.insert(pelicula.id)
        }
        UserDefaults.standard.set(Array(ids), forKey: llave)
    }
}
