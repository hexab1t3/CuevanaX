//
//  FindViewModel.swift
//  Cuevana
//

import Foundation

@Observable
class FindViewModel {
    var searchText = ""
    
    var filteredMovies: [Movie] {
        if searchText.isEmpty {
            return []
        } else {
            return ExampleMovies.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
}

