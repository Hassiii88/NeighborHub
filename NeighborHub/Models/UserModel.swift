//
//  UserModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var area: String
    var profileImageURL: String
    var rating: Double
    var totalReviews: Int
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case area
        case profileImageURL
        case rating
        case totalReviews
        case createdAt
    }
    
    // Empty init — new user banate waqt
    init(id: String = "", name: String, email: String, area: String) {
        self.id = id
        self.name = name
        self.email = email
        self.area = area
        self.profileImageURL = ""
        self.rating = 0.0
        self.totalReviews = 0
        self.createdAt = Date()
    }
}