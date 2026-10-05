//
//  ChatViewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import Foundation
import FirebaseFirestore
import Combine

class ChatViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var chats: [ChatModel] = []
    @Published var messages: [MessageModel] = []
    @Published var messageText: String = ""
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var currentChatId: String = ""
    
    // MARK: - Private
    private var chatsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    
    // MARK: - Fetch All Chats
    func fetchChats(userId: String) {
        isLoading = true
        chatsListener?.remove()
        
        chatsListener = ChatService.shared.fetchChats(userId: userId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let chats):
                    self.chats = chats
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Open Chat
    func openChat(
        currentUserId: String,
        currentUserName: String,
        otherUserId: String,
        otherUserName: String,
        postId: String,
        postTitle: String,
        completion: @escaping (String) -> Void
    ) {
        ChatService.shared.getOrCreateChat(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            postId: postId,
            postTitle: postTitle
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let chatId):
                    self.currentChatId = chatId
                    self.fetchMessages(chatId: chatId)
                    completion(chatId)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Fetch Messages
    func fetchMessages(chatId: String) {
        messagesListener?.remove()
        
        messagesListener = ChatService.shared.fetchMessages(chatId: chatId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    self.messages = messages
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Send Message
    func sendMessage(chatId: String, senderId: String, senderName: String) {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        isSending = true
        
        let message = MessageModel(
            text: text,
            senderId: senderId,
            senderName: senderName
        )
        
        ChatService.shared.sendMessage(chatId: chatId, message: message) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSending = false
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Get Other User Name
    func getOtherUserName(chat: ChatModel, currentUserId: String) -> String {
        guard let index = chat.participants.firstIndex(where: { $0 != currentUserId }),
              index < chat.participantNames.count else {
            return "Unknown"
        }
        return chat.participantNames[index]
    }
    
    // MARK: - Deinit
    deinit {
        chatsListener?.remove()
        messagesListener?.remove()
    }
}

