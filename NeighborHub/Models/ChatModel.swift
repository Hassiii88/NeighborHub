//
//  ChatModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore

struct ChatModel: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]        // [userId1, userId2]
    var participantNames: [String]    // [name1, name2]
    var lastMessage: String
    var lastMessageTime: Date
    var unreadCount: Int
    var postId: String                // Kis post ke baare mein chat hai
    var postTitle: String
    
    init(
        participants: [String],
        participantNames: [String],
        postId: String,
        postTitle: String
    ) {
        self.participants = participants
        self.participantNames = participantNames
        self.lastMessage = ""
        self.lastMessageTime = Date()
        self.unreadCount = 0
        self.postId = postId
        self.postTitle = postTitle
    }
}