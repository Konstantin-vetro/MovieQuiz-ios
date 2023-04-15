//
//  MovieQuizViewControllerMock.swift
//  MovieQuizViewControllerMock
//

import XCTest
@testable import MovieQuiz

class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func present(_ alertController: UIAlertController) { }
    
    func show(quiz step: QuizStepViewModel) { }
    
    func show(quiz result: QuizResultsViewModel) { }
    
    func highlightImageBorder(isCorrectAnswer: Bool) { }
    
    func buttonsIsNotEnabled() { }
    
    func showLoadingIndicator() { }
    
    func hideLoadingIndicator() { }
    
    func backgroundTransparency() { }
    
    func showNetworkError(message: String) { }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
