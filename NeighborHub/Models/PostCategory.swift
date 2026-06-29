//
//  PostCategory.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore

enum PostCategory: String, Codable, CaseIterable {
    case sell = "Sell"
    case rent = "Rent"
    case service = "Service"
    case emergency = "Emergency"
    case event = "Event"
    case lostFound = "Lost & Found"
    
    var icon: String {
        switch self {
        case .sell:      return "tag.fill"
        case .rent:      return "house.fill"
        case .service:   return "wrench.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .event:     return "calendar"
        case .lostFound: return "magnifyingglass"
        }
    }
}

struct PostModel: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var category: PostCategory
    var price: Double
    var imageURLs: [String]
    var userId: String
    var userName: String
    var userProfileURL: String
    var area: String
    var latitude: Double
    var longitude: Double
    var isActive: Bool
    var createdAt: Date
    
    // Empty init — new post banate waqt
    init(
        title: String,
        description: String,
        category: PostCategory,
        price: Double = 0.0,
        userId: String,
        userName: String,
        area: String,
        latitude: Double = 0.0,
        longitude: Double = 0.0
    ) {
        self.title = title
        self.description = description
        self.category = category
        self.price = price
        self.imageURLs = []
        self.userId = userId
        self.userName = userName
        self.userProfileURL = ""
        self.area = area
        self.latitude = latitude
        self.longitude = longitude
        self.isActive = true
        self.createdAt = Date()
    }
}