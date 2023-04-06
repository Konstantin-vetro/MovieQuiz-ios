//
//  NetworkClient.swift
//  MovieQuiz
//

import Foundation

///Модель, отвечающая  за загрузку данных по URL
struct NetworkClient {
    //сетевая ошибка
    private enum NetworkError: Error {
        case codeError
    }
    
    //метод запроса
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        //создаем запрос
        let request = URLRequest(url: url)
        //обрабатываем ответ
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        //распаковываем ошибки
            if let error = error {
                handler(.failure(error))
                return
            }
        //Проверка, что нам пришел успешный код ответа
            if let response = response as? HTTPURLResponse,     //превращаем в объект класса HTTPURLResponse
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
        //возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
