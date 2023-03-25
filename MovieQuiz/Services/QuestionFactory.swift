import Foundation
import UIKit
class QuestionFactory: QuestionFactoryProtocol {
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false)
//    ]
    private let moviesLoader: MoviesLoadingProtocol //загрузчик фильмов
    private var movies: [MostPopularMovie] = []     //хранилище фильмов с сервера
    private weak var delegate: QuestionFactoryDelegate?   //создаем делегат с которым общается фабрика
    
    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate) {      //инъекция зависимостей через инициализатор
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    //загрузка данных о фильмах
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        //запускаем код в другом потоке
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            //выбираем произвольный элемент из массива
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return}
            // обработка ошибки загрузки данных из URL
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Ошибка загрузки изображения")
            }
            // создание вопроса, определение его корректности
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше, чем 7?"
            let correctAnswer = rating > 7
            //создание модели вопроса
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            //возвращаемся в главный поток через делегат
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
