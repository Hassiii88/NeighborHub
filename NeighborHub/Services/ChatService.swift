//
//  ChatService.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatService {
    static let shared = ChatService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: - Create or Get Existing Chat
    func getOrCreateChat(
        currentUserId: String,
        currentUserName: String,
        otherUserId: String,
        otherUserName: String,
        postId: String,
        postTitle: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Check if chat already exists
        db.collection(Constants.Collections.chats)
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Find existing chat with same participants + post
                let existingChat = snapshot?.documents.first(where: { doc in
                    let data = doc.data()
                    let participants = data["participants"] as? [String] ?? []
                    let chatPostId = data["postId"] as? String ?? ""
                    return participants.contains(otherUserId) && chatPostId == postId
                })
                
                if let existing = existingChat {
                    completion(.success(existing.documentID))
                    return
                }
                
                // Create new chat
                let chat = ChatModel(
                    participants: [currentUserId, otherUserId],
                    participantNames: [currentUserName, otherUserName],
                    postId: postId,
                    postTitle: postTitle
                )
                
                do {
                    let ref = try self.db
                        .collection(Constants.Collections.chats)
                        .addDocument(from: chat)
                    completion(.success(ref.documentID))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Fetch All Chats for Current User
    func fetchChats(
        userId: String,
        completion: @escaping (Result<[ChatModel], Error>) -> Void
    ) -> ListenerRegistration {
        let listener = db
            .collection(Constants.Collections.chats)
            .whereField("participants", arrayContains: userId)
            .order(by: "lastMessageTime", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let chats = snapshot?.documents.compactMap {
                    try? $0.data(as: ChatModel.self)
                } ?? []
                completion(.success(chats))
            }
        return listener
    }
    
    // MARK: - Fetch Messages (Real-time)
    func fetchMessages(
        chatId: String,
        completion: @escaping (Result<[MessageModel], Error>) -> Void
    ) -> ListenerRegistration {
        let listener = db
            .collection(Constants.Collections.chats)
            .document(chatId)
            .collection(Constants.Collections.messages)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let messages = snapshot?.documents.compactMap {
                    try? $0.data(as: MessageModel.self)
                } ?? []
                completion(.success(messages))
            }
        return listener
    }
    
    // MARK: - Send Message
    func sendMessage(
        chatId: String,
        message: MessageModel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            try db
                .collection(Constants.Collections.chats)
                .document(chatId)
                .collection(Constants.Collections.messages)
                .addDocument(from: message)
            
            // Update last message in chat
            db.collection(Constants.Collections.chats)
                .document(chatId)
                .updateData([
                    "lastMessage": message.text,
                    "lastMessageTime": Timestamp(date: message.timestamp),
                    "unreadCount": FieldValue.increment(Int64(1))
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Mark Messages as Read
    func markAsRead(chatId: String, userId: String) {
        db.collection(Constants.Collections.chats)
            .document(chatId)
            .updateData(["unreadCount": 0]) { _ in }
    }
}