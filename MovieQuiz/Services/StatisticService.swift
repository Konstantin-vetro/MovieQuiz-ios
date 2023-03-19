//
//  StatisticService.swift
//  MovieQuiz
//
//сущность для взаимодействия с UserDefaults
import Foundation
//результат одной игры
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}
//расширение методом сравнения с помощью протокола Comparable
extension GameRecord: Comparable {
    //метод сравнения рекордов
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
}

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard
    //Ключи
    private enum Keys: String {
        case correct, total, bestGame, gamesCount//, accuracy
    }
    //средняя точность правильных ответов за все игры в процентах
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
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
        //var oneGame = Double(count/amount) * 100
        //let differentGame = oneGame + oneGame
        //let accuracy = differentGame / Double(gamesCount)
        let totalAccuracy: Double = ((Double(amount) * self.totalAccuracy + Double(count))/Double(amount * (gamesCount + 1))) * 100
        //let accuracyResult: Double = ((Double(gamesCount * amount) * totalAccuracy + Double(count))/Double(amount * (gamesCount + 1))) * 100
        let currentRecord = GameRecord(correct: count, total: amount, date: Date())
        let newBestGame = bestGame
        userDefaults.set(totalAccuracy, forKey: Keys.total.rawValue)
        userDefaults.set(gamesCount + 1, forKey: Keys.gamesCount.rawValue)
        userDefaults.set(try! JSONEncoder().encode(currentRecord), forKey: Keys.bestGame.rawValue)
        
        newBestGame < currentRecord
        
//        if currentRecord.correct < bestGame.correct {
//            userDefaults.set(bestGame.correct, forKey: Keys.correct.rawValue)
//        } else {
//            userDefaults.set(bestGame.correct, forKey: Keys.correct.rawValue)
//        }
    }
}
