//
//  MovieQuizPresenter.swift
//  MovieQuiz
//

import UIKit

final class MovieQuizPresenter {
    
    //индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    //общее количество вопросов для квиза
    let questionsAmount: Int = 10
    
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
}
