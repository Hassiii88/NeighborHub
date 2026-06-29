//
//  MessageModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore

struct MessageModel: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var senderId: String
    var senderName: String
    var timestamp: Date
    var isRead: Bool
    
    init(text: String, senderId: String, senderName: String) {
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = Date()
        self.isRead = false
    }
}