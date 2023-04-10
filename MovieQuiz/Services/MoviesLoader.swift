//
//  MoviesLoader.swift
//  MovieQuiz
//

import Foundation
//протокол для загрузчика фильмов
protocol MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
//загрузчик фильмов
struct MoviesLoader: MoviesLoadingProtocol {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    // MARK: - key_imDb
    private let keyImdb: String = "k_y4y8zf62"
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        // получаем API
        let api = "https://imdb-api.com/en/API/Top250Movies/\(keyImdb)"
        //проверка на преобразование строки
        guard let url = URL(string: api) else {
            preconditionFailure("Не удалось создать URL-адрес Top250Movies")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
