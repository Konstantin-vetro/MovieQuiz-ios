//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Гость on 12.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    //метод который должен быть у фабрики вопросов
}
