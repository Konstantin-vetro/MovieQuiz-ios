import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - UI-Outlets
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Swipes
    private var yesSwipe: UISwipeGestureRecognizer?
    private var noSwipe: UISwipeGestureRecognizer?
    
    // MARK: - Presenter
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20   //скругление углов изображения по радиусу 20
        swipeGestures()
    }
    
    // MARK: - Gesture swipes
    /// данные жесты сделаны для теста на имеющемся IPhone 6s,
    /// учитывая, что кнопки не помещяются на экране
    /// свайп вправо  эквивалентен кнопке ДА
    /// свайп влево эквивалентен кнопке НЕТ

    private func swipeGestures() {
        yesSwipe = UISwipeGestureRecognizer(target: self, action: #selector(correctSwipe))
        noSwipe = UISwipeGestureRecognizer(target: self, action: #selector(incorrectSwipe))
        noSwipe?.direction = .left
        if let yesSwipe {
            imageView.addGestureRecognizer(yesSwipe)
        }
        if let noSwipe {
            imageView.addGestureRecognizer(noSwipe)
        }
        imageView.isUserInteractionEnabled = true
    }
    
    @IBAction private func correctSwipe(_ gesture: UISwipeGestureRecognizer) {  // обработка ответа Да жестом
        if gesture.state == .ended {
            presenter.yesButtonClicked()
        }
    }
    
    @IBAction private func incorrectSwipe(_ gesture: UISwipeGestureRecognizer) {    // обработка ответа Нет жестом
        if gesture.state == .ended {
            presenter.noButtonClicked()
        }
    }
    
    // MARK: - StatusBar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return.lightContent
    }
    
    // MARK: - UI-Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Functions show
    func show(quiz step: QuizStepViewModel) {       // Метод показа модели
        imageView.layer.borderColor = UIColor.clear.cgColor
        //заполнение картинки, вопроса и счётчика данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // включаем кнопки когда данные полученны
        yesButton.isEnabled = true
        noButton.isEnabled = true
        // жесты включены
        yesSwipe?.isEnabled = true
        noSwipe?.isEnabled = true
        view.alpha = 1                          // прозрачный фон
        hideLoadingIndicator()
    }
    
    func show(quiz result: QuizResultsViewModel) {      // метод показа результата
        let message = presenter.makeResultMessage()
        
        let alert = UIAlertController(title: result.title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.presenter.restartGame()
        }
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "Game results"
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Auxiliary functions
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    // выключение кнопок
    func buttonsIsNotEnabled() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        yesSwipe?.isEnabled = false
        noSwipe?.isEnabled = false
    }
    // показ индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false      
        activityIndicator.startAnimating()
    }
    // скрытие индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    // прозрачность фона на 60 %
    func backgroundTransparency() {
        view.alpha = 0.6
    }
    // MARK: - Network
    // метод состояния ошибки при загрузке данных
    func showNetworkError(message: String) {
        //hideLoadingIndicator()
        //backgroundTransparency()        // прозрачность на 60%
       
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать еще раз", style: .default) { [weak self] _ in
            guard let self else { return }
            self.presenter.loadData()
        }
        alert.addAction(action)
        self.present(alert, animated: true)
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
