//
//  MoviesLoader.swift
//  MovieQuiz
//

///Загрузчик фильмов
import Foundation
//протокол для загрузчика фильмов
protocol MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
//загрузчик фильмов
struct MoviesLoader: MoviesLoadingProtocol {
    // NetworkClient
    private let networkClient = NetworkClient()
    
    // URL
    private var mostPopularMoviesUrl: URL {
        // получаем API
        let api = "https://imdb-api.com/en/API/MostPopularMovies/k_y4y8zf62"
        //проверка на преобразование строки
        guard let url = URL(string: api) else {
            preconditionFailure("Не удалось создать URL-адрес mostPopularMoviesUrl")
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
