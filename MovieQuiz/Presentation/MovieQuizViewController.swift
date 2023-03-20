import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertDelegate {
    //аутлеты кнопок
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    //аутлеты ui-элементов
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
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
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)   //задаем делегат фабрике вопросов
        alertResult = AlertPresenter(delegate: self)        //задаем делегат алерту
        statisticService = StatisticServiceImplementation()
        questionFactory?.requestNextQuestion()
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
        //показываем алерт
        present(alertController, animated: true)
    }
    // MARK: - Actions
    //create yesButton
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    //create noButton
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    // MARK: - Private functions
    //метод конвертации
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") // высчитываем номер вопроса
    }
    //метод показа модели
    private func show(quiz step: QuizStepViewModel) {
        //заполнение картинки, вопроса и счётчика данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
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
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(statisticService!.gamesCount)\nРекорд: \(statisticService!.bestGame.correct)/\(statisticService!.bestGame.total) (\(statisticService!.bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statisticService!.totalAccuracy))%"
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз") { [weak self] _ in
                    guard let self = self else { return }
                    //после результатов рамка картинки исчезает
                    self.imageView.layer.borderWidth = 0
                    //обнуляем счетчик правильных ответов по итогу результатов
                    self.correctAnswers = 0
                    self.yesButton.isEnabled = true
                    self.noButton.isEnabled = true
                    self.currentQuestionIndex = 0
                    self.questionFactory?.requestNextQuestion()
                }
            alertResult?.createAlertController(from: alertModel)
        } else {
            imageView.layer.borderWidth = 0
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
            //после отображения данных включаем кнопки
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
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
