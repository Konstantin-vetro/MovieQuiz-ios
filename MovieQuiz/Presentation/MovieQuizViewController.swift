import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertDelegate {
    // MARK: - UI-Outlets
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    // MARK: - Private variables
    //индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    //счетчик правильных ответов
    private var correctAnswers: Int = 0
    //общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    //фабрика вопросов реализуется протоколом: менять на web здесь
    private var questionFactory: QuestionFactoryProtocol?
    //текущий вопрос
    private var currentQuestion: QuizQuestion?
    //алерт результата текущей игры
    private var alertResult: AlertProtocol?
    //экземпляр класса statisticService
    private var statisticService: StatisticServiceProtocol?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20   //скругление углов изображения по радиусу 20
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)   //делегат фабрики вопросов
        alertResult = AlertPresenter(delegate: self)        // делегат алерта
        statisticService = StatisticServiceImplementation()
        questionFactory?.loadData()     //загрузка данных
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // MARK: - AlertDelegate
    
    func presentAlertController(_ alertController: UIAlertController) {
        present(alertController, animated: true)        //показ алерта
    }
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    // MARK: - Private functions
    /// Метод конвертации
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
    }
    /// Метод показа модели
    private func show(quiz step: QuizStepViewModel) {
        //заполнение картинки, вопроса и счётчика данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // включаем кнопки когда данные полученны
        yesButton.isEnabled = true
        noButton.isEnabled = true
        view.alpha = 1                          // прозрачный фон
        activityIndicator.isHidden = true       //индикатор загрузки скрыт
    }
    /// Метод показа результата ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        //выключаем кнопки до начала смены вопроса, чтобы не было повторных нажатий
        yesButton.isEnabled = false
        noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    /// Метод показа следующего вопроса или результата игры
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let recordString = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let accuracyString = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
            let text = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(statisticService.gamesCount)
                            Рекорд: \(recordString)(\(statisticService.bestGame.date.dateTimeString))
                            Средняя точность: \(accuracyString)
                        """
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз") { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.imageView.layer.borderWidth = 0        //после результатов рамка картинки исчезает
                    
                    self.correctAnswers = 0                     //обнуляем счетчик правильных ответов по итогу результатов
                    self.yesButton.isEnabled = true
                    self.noButton.isEnabled = true
                    self.currentQuestionIndex = 0
                    self.questionFactory?.requestNextQuestion()
                }
            guard let alertResult = alertResult else {return}   //распаковка результата алерта
            alertResult.createAlertController(from: alertModel)
        } else {
            imageView.layer.borderWidth = 0
            currentQuestionIndex += 1
            activityIndicator.isHidden = false
            questionFactory?.requestNextQuestion()
        }
    }
    // MARK: - Network
    //метод показа индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false      //показываем индикатор загрузки
        activityIndicator.startAnimating()      //включаем анимацию
    }
    ///метод состояния ошибки при загрузке данных
    private func showNetworkError(message: String) {

        let alertModel = AlertModel(title: "Что-то пошло не так(",
                                    message: message,
                                    buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self else { return }
            self.imageView.layer.borderWidth = 0
            self.correctAnswers = 0
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.currentQuestionIndex = 0
            self.questionFactory?.loadData()
            self.view.alpha = 1
        }
        view.alpha = 0.6                        //прозрачность на 60%
        guard let alertResult else { return }
        alertResult.createAlertController(from: alertModel)
    }
    //данные с сервера загружены
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true   //скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    //произошла ошибка загрузки данных
    func didFailToLoadData(with error: Error) {
        activityIndicator.isHidden = false
        showNetworkError(message: "Невозможно загрузить данные")//error.localizedDescription)   //сообщение с описанием ошибки
    }
    //ошибка загрузки изображения
    func failedToUploadImage(for quizQuestionIndex: Int) {
        activityIndicator.isHidden = false
        let alert = AlertModel(title: "Ошибка",
                               message: "Не удалось загрузить изображение",
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self else { return }
            self.imageView.layer.borderWidth = 0
            self.questionFactory?.requestNextQuestionByIndex(by: quizQuestionIndex)
        }
        view.alpha = 0.6            //прозрачность на 60%
        alertResult?.createAlertController(from: alert)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
