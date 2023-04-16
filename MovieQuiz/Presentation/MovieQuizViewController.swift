import UIKit

// протокол для тестов
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func setButtonsEnabled(isEnable: Bool)
    func hideLoadingIndicator()
    
    func backgroundTransparency()
    func showNetworkError(message: String)
    
    func present(_ alertController: UIAlertController)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - UI-Outlets
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
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
        setButtonsEnabled(isEnable: true)
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
        self.present(alert)
    }
    // MARK: - presentAlertController
    func present(_ alertController: UIAlertController) {
        self.present(alertController, animated: true)
    }
    // MARK: - Auxiliary functions
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    // включение/выключение кнопок/жестов
    func setButtonsEnabled(isEnable: Bool) {
        yesButton.isEnabled = isEnable
        noButton.isEnabled = isEnable
        yesSwipe?.isEnabled = isEnable
        noSwipe?.isEnabled = isEnable
    }
    // показ индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.startAnimating()
    }
    // скрытие индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    // прозрачность фона на 60 %
    func backgroundTransparency() {
        view.alpha = 0.6
    }
    // MARK: - Network
    // метод состояния ошибки при загрузке данных
    func showNetworkError(message: String) {
      
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать еще раз", style: .default) { [weak self] _ in
            guard let self else { return }
            self.presenter.loadData()
        }
        alert.addAction(action)
        self.present(alert)
    }
}
