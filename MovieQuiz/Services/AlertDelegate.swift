//
//  AlertDelegate.swift
//  MovieQuiz
//

import Foundation
import UIKit
//делегат для алерта
protocol AlertDelegate: AnyObject {
    func presentAlertController(_ alertController: UIAlertController)
}
