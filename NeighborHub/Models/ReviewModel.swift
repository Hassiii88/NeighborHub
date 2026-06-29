//
//  ReviewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore

struct ReviewModel: Identifiable, Codable {
    @DocumentID var id: String?
    var reviewerId: String
    var reviewerName: String
    var reviewedUserId: String
    var rating: Int          // 1 to 5
    var comment: String
    var createdAt: Date
    
    init(
        reviewerId: String,
        reviewerName: String,
        reviewedUserId: String,
        rating: Int,
        comment: String
    ) {
        self.reviewerId = reviewerId
        self.reviewerName = reviewerName
        self.reviewedUserId = reviewedUserId
        self.rating = rating
        self.comment = comment
        self.createdAt = Date()
    }
}