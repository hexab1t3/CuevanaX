//
//  FindViewModel.swift
//  Cuevana
//

import Foundation
import Observation

@Observable
class FindViewModel {

    enum ViewState: Equatable {
        case idle
        case loading
        case results([Movie])
        case empty
        case error(String)
    }

    private(set) var state: ViewState = .idle

    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            scheduleSearch()
        }
    }

    var filteredMovies: [Movie] {
        if case .results(let list) = state { return list }
        return []
    }

    private let service: MovieServiceProtocol
    private let debounceNanoseconds: UInt64
    private var searchTask: Task<Void, Never>? = nil

    init(service: MovieServiceProtocol = MovieServices(), debounceNanoseconds: UInt64 = 300_000_000) {
        self.service = service
        self.debounceNanoseconds = debounceNanoseconds
    }

    // Breve pausa para evitar saturar la API mientras el usuario teclea
    private func scheduleSearch() {
        searchTask?.cancel()
        let query = searchText
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state = .idle
            return
        }
        searchTask = Task { [debounceNanoseconds] in
            try? await Task.sleep(nanoseconds: debounceNanoseconds)
            guard !Task.isCancelled else { return }
            await performSearch(for: query)
        }
    }

    @MainActor
    func performSearch(for query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            state = .idle
            return
        }

        state = .loading

        do {
            let results = try await service.searchMovies(query: trimmedQuery)
            guard !Task.isCancelled else { return }
            state = results.isEmpty ? .empty : .results(results)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    func retry() async {
        await performSearch(for: searchText)
    }
}
