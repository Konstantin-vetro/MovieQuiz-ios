//
//  AlertPresenter.swift
//  MovieQuiz
//

import Foundation
import UIKit
//create an alert class
class AlertPresenter: AlertProtocol {
    //создаем делегат со слабой ссылкой
    weak var delegate: AlertDelegate?
    
    init(delegate: AlertDelegate) {     //инъекция зависимостей через инициализатор
        self.delegate = delegate
    }
    
    func createAlertController(from alert: AlertModel) {
        //создаем alertController
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Game results"     //identifier for tests
        //создаем actionController
        let alertAction = UIAlertAction(title: alert.buttonText, style: .default, handler: alert.completion)
        //связываем alert и action
        alertController.addAction(alertAction)
        //показ по методу делегата
        delegate?.presentAlertController(alertController)       
    }

}
