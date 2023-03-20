//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Гость on 12.03.2023.
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
