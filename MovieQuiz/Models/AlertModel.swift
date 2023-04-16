//
//  AlertModel.swift
//  MovieQuiz
//

import Foundation
import UIKit
//create an alert model
struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: ((UIAlertAction) -> Void)
}
