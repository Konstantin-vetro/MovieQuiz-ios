//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Гость on 25.03.2023.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
    var resizedImageURL: URL {
        // создаем строку из адреса
        let urlString = imageURL.absoluteString
        // обрезаем лишнюю часть и добавляем модификатор желаемого качества
        let imageUrlString = urlString.components(separatedBy: "._") [0] + ".V0_UX600_.jpg"
        // создаем нвоый адрес, при ошибке возвращаем старый
        guard let newURL = URL(string: imageUrlString) else { return imageURL}
        // возвращаем новый адрес
        return newURL
    }
}
