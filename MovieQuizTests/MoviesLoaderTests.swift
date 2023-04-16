//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
// MARK: - white-box test
import XCTest
@testable import MovieQuiz

// MARK: - test networkClient

struct StubNetworkClient: NetworkRouting {
    // тестовая ошибка
    enum TestError: Error {
        case test
    }
    
    let emulatorError: Bool  // этот параметр нужен для того, чтобы заглушка эмулировала либо ошибку сети, либо успешный ответ
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulatorError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
    
    private var expectedResponse: Data {
                """
                {
                   "errorMessage" : "",
                   "items" : [
                      {
                         "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                         "fullTitle" : "Prey (2022)",
                         "id" : "tt11866324",
                         "imDbRating" : "7.2",
                         "imDbRatingCount" : "93332",
                         "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "1",
                         "rankUpDown" : "+23",
                         "title" : "Prey",
                         "year" : "2022"
                      },
                      {
                         "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                         "fullTitle" : "The Gray Man (2022)",
                         "id" : "tt1649418",
                         "imDbRating" : "6.5",
                         "imDbRatingCount" : "132890",
                         "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                         "rank" : "2",
                         "rankUpDown" : "-1",
                         "title" : "The Gray Man",
                         "year" : "2022"
                      }
                    ]
                  }
                """.data(using: .utf8) ?? Data()
    }
}

final class MoviesLoaderTests: XCTestCase {
    // тест для проверки успешной загрузки
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulatorError: false) // эмилируем ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let expactation = expectation(description: "Loading expactation")
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expactation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
    // тест для проверки ошибки
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulatorError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let expactation = expectation(description: "Loading expectation")
        loader.loadMovies { result in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expactation.fulfill()
            case .success(_):
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
}
