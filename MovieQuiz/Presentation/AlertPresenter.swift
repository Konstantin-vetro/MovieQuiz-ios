//
//  AlertPresenter.swift
//  MovieQuiz
//

import Foundation
import UIKit
 
class AlertPresenter: AlertProtocol {
    // делегат со слабой ссылкой
    weak var delegate: AlertDelegate?
    
    init(delegate: AlertDelegate) {     //инъекция зависимостей через инициализатор
        self.delegate = delegate
    }
    
    func createAlertController(from alert: AlertModel) {
        
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "Game results"     //identifier for tests
        
        let alertAction = UIAlertAction(title: alert.buttonText, style: .default, handler: alert.completion)
        
        alertController.addAction(alertAction)
        
        delegate?.presentAlertController(alertController)       
    }

}
