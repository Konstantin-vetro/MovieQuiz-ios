//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//

import Foundation

///Делегаты фабрики вопросов
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    //метод который должен быть у фабрики вопросов
    func didLoadDataFromServer()                            //сообщение об успешной загрузке
    func didFailToLoadData(with error: Error)               //сообщение об ошибке загрузки
    func failedToUploadImage(for quizQuestionIndex: Int)    //метод загрузки изображения при ошибке
}
