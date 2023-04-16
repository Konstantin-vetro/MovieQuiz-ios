//
//  StatisticService.swift
//  MovieQuiz
//
//сущность для взаимодействия с UserDefaults
import Foundation
// модель рекорда игры
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    //метод сравнения рекордов с помощью протокола Comparable
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
}

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    //правильный ответ
    var correct: Int {
        get {
            return userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    //количество правильных ответов
    var total: Int {
        get {
            return userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    //средняя точность правильных ответов за все игры в процентах
    var totalAccuracy: Double {
        (Double(correct) / Double(total)) * 100
    }
    //количество завершённых игр
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    //информация о лучшей попытке
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    //метод для сохранения текущего результата игры
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correct += count
        total += amount
        //сравнение для сохранения лучшего результата в userDefaults
        if bestGame.correct < count {
            bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
    }
}
