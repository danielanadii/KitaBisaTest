//
//  Movies.swift
//  KitaBisa TechTest
//
//  Created by Daniel Anadi on 12/12/20.
//

import Foundation

class MovieResponse: Decodable {
    let page: Int
    let results: [Movies]
    let total_results: Int
    let total_pages: Int
}

class Movies: Decodable {
    let poster_path: String?
    let adult: Bool?
    let overview: String?
    let release_date: String?
//    let genre_ids: [Int]?
    let id: Int?
    let original_title: String?
    let original_language: String?
    let title: String?
    let backdrop_path: String?
    let popularity: Float?
    let vote_count: Int?
    let video: Bool?
    let vote_average: Float?
}

class MovieObject: NSObject {
    var poster_path: String?
    var adult: Bool?
    var overview: String?
    var release_date: String?
//    var genre_ids: [Int]?
    var id: Int?
    var original_title: String?
    var original_language: String?
    var title: String?
    var backdrop_path: String?
    var popularity: Float?
    var vote_count: Int?
    var video: Bool?
    var vote_average: Float?
}

struct FavMovie {
    let id: Int
    let overview: String
    let poster_path: String
    let release_date: String
    let title: String
    
}

class Dates: Decodable {
    let maximum: String?
    let minimum: String?
}
