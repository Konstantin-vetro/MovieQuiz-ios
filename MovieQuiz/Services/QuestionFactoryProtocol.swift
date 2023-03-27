import Foundation
/// Протокол фабрики вопросов
protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func requestNextQuestionByIndex(by index: Int)
    func loadData()
}
