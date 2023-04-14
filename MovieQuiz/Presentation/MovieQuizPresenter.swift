//
//  MovieQuizPresenter.swift
//  MovieQuiz
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertDelegate {
    // MARK: - private variables
    private var questionFactory: QuestionFactoryProtocol?   // фабрика вопросов
    private weak var viewController: MovieQuizViewController?
    private let statisticService: StatisticServiceProtocol! //экземпляр класса statisticService
    private var alertResult: AlertPresenter?
    
    private var currentQuestionIndex: Int = 0   //индекс текущего вопроса
    private let questionsAmount: Int = 10   //общее количество вопросов для квиза
    private var currentQuestion: QuizQuestion? // текущий вопрос
    private var correctAnswers: Int = 0 // счетчик правильных вопросов
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertResult = AlertPresenter(delegate: self)        // делегат алерта
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.viewController?.show(quiz: viewModel)
        }
    }
    // MARK: - AlertDelegate
    func presentAlertController(_ alertController: UIAlertController) {
        guard let viewController else { return }
        viewController.present(alertController, animated: true)        //показ алерта
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    /// Метод конвертации
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
    }
    // MARK: - Buttons
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // перезагрузка игры
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Show
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    // Метод показа результата ответа
    private func proceedWithAnswer(isCorrect: Bool) {
        viewController?.buttonsIsNotEnabled()   // выключение кнопок и жестов
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    // метод показа результата игры или перехода на следующий вопрос
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = correctAnswers == self.questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    // сообщения о результатах квиза
    func makeResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let recordString = "\(bestGame.correct)/\(bestGame.total)"
        let accuracyString = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
        let text = """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Количество сыгранных квизов: \(statisticService.gamesCount)
                        Рекорд: \(recordString)(\(statisticService.bestGame.date.dateTimeString))
                        Средняя точность: \(accuracyString)
                    """
        return text
    }

    // MARK: - Network
    // загрузка фабрики вопросов
    func loadData() {
        questionFactory?.loadData()
    }
    // данные с сервера загружены
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    // ошибка загрузки данных с сервера
    func didFailToLoadData(with error: Error) {
        //let message = error.localizedDescription
        viewController?.backgroundTransparency()
        viewController?.showNetworkError(message: "Невозможно загрузить данные")
    }
    // ошибка загрузки данных изображения
    func failedToUploadImage(for quizQuestionIndex: Int) {
        viewController?.backgroundTransparency()
        viewController?.showLoadingIndicator()
//        можно и так и так реализовать показ алерта
//        let alert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить изображение", preferredStyle: .alert)
//
//        let action = UIAlertAction(title: "Попробовать еще раз", style: .default) { [weak self] _ in
//            guard let self else { return }
//            self.questionFactory?.requestNextQuestionByIndex(by: quizQuestionIndex)
//        }
//
//        alert.addAction(action)
//
//        viewController?.present(alert, animated: true)
        
        let alertModel = AlertModel(title: "Hello", message: "World", buttonText: "OK") { [weak self] _ in
            guard let self else { return }
            self.questionFactory?.requestNextQuestionByIndex(by: quizQuestionIndex)
        }
        alertResult?.createAlertController(from: alertModel)
    }
}
