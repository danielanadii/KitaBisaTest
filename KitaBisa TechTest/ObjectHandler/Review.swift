//
//  Review.swift
//  KitaBisa TechTest
//
//  Created by Daniel Anadi on 13/12/20.
//

import Foundation

class ReviewResponse: Decodable {
    let id: Int
    let page: Int
    let results: [Review]
    let total_pages: Int
    let total_results: Int
}

class Review: Decodable {
    let author: String
    let author_details: authorDetails
    let content: String
    let created_at: String
    let id: String
    let updated_at: String
    let url: String
}

class authorDetails: Decodable {
    let name: String?
    let username: String?
    let avatar_path: String?
    let rating: Float?
}

class ReviewObject: NSObject {
    var author: String?
    var avatar_path: String?
    var content: String?
    var created_at: String?
    var id: String?
    var updated_at: String?
    var url: String?
}
