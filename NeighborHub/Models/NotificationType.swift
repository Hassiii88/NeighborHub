//
//  NotificationType.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore

enum NotificationType: String, Codable {
    case newMessage = "new_message"
    case newReview = "new_review"
    case emergency = "emergency"
    case eventReminder = "event_reminder"
    case postInterest = "post_interest"
}

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var body: String
    var type: NotificationType
    var isRead: Bool
    var relatedId: String     // postId ya chatId ya eventId
    var createdAt: Date
    
    init(
        userId: String,
        title: String,
        body: String,
        type: NotificationType,
        relatedId: String = ""
    ) {
        self.userId = userId
        self.title = title
        self.body = body
        self.type = type
        self.isRead = false
        self.relatedId = relatedId
        self.createdAt = Date()
    }
}