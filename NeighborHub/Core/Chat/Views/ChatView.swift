//
//  ChatView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import SwiftUI

struct ChatView: View {
    
    var otherUserId: String
    var otherUserName: String
    var currentUser: UserModel
    var postId: String
    var postTitle: String
    
    @StateObject private var chatViewModel = ChatViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var chatId: String = ""
    @State private var isLoadingChat: Bool = true
    
    var body: some View {
        ZStack {
            Color(hex: "1A1A2E").ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Top Bar
                topBar
                
                // MARK: - Post Reference Banner
                postBanner
                
                // MARK: - Messages
                if isLoadingChat {
                    loadingView
                } else {
                    messagesView
                }
                
                // MARK: - Message Input
                messageInputBar
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $chatViewModel.showError) {
            Button("OK") { chatViewModel.showError = false }
        } message: {
            Text(chatViewModel.errorMessage)
        }
        .onAppear {
            setupChat()
        }
    }
    
    // MARK: - Setup Chat
    private func setupChat() {
        guard let currentUserId = currentUser.id else { return }
        
        chatViewModel.openChat(
            currentUserId: currentUserId,
            currentUserName: currentUser.name,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            postId: postId,
            postTitle: postTitle
        ) { id in
            chatId = id
            isLoadingChat = false
            ChatService.shared.markAsRead(chatId: id, userId: currentUserId)
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(String(otherUserName.prefix(1)).uppercased())
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "E94560"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(otherUserName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(hex: "16213E"))
        .overlay(
            Divider()
                .background(Color.white.opacity(0.08)),
            alignment: .bottom
        )
    }
    
    // MARK: - Post Banner
    private var postBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "tag.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "E94560"))
            
            Text("Re: \(postTitle)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(hex: "E94560").opacity(0.08))
        .overlay(
            Divider()
                .background(Color.white.opacity(0.06)),
            alignment: .bottom
        )
    }
    
    // MARK: - Messages View
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isFromCurrentUser: message.senderId == currentUser.id
                        )
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: chatViewModel.messages.count) { _ in
                if let lastId = chatViewModel.messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Color(hex: "E94560"))
            Text("Loading conversation...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 10)
            Spacer()
        }
    }
    
    // MARK: - Message Input Bar
    private var messageInputBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.08))
            
            HStack(spacing: 12) {
                
                // Text Field
                HStack {
                    TextField("", text: $chatViewModel.messageText)
                        .placeholder(when: chatViewModel.messageText.isEmpty) {
                            Text("Type a message...")
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .foregroundColor(.white)
                        .tint(Color(hex: "E94560"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.07))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Send Button
                Button {
                    if let userId = currentUser.id {
                        chatViewModel.sendMessage(
                            chatId: chatId,
                            senderId: userId,
                            senderName: currentUser.name
                        )
                    }
                } label: {
                    ZStack {
                        if chatViewModel.isSending {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .background(
                        chatViewModel.messageText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                        ? Color(hex: "E94560").opacity(0.4)
                        : Color(hex: "E94560")
                    )
                    .clipShape(Circle())
                }
                .disabled(
                    chatViewModel.messageText.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty || chatViewModel.isSending
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(hex: "16213E"))
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    var message: MessageModel
    var isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(isFromCurrentUser ? .white : .white.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                        ? Color(hex: "E94560")
                        : Color(hex: "16213E")
                    )
                    .cornerRadius(18, corners: isFromCurrentUser
                                  ? [.topLeft, .topRight, .bottomLeft]
                                  : [.topLeft, .topRight, .bottomRight])
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isFromCurrentUser
                                ? Color.clear
                                : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                
                Text(message.timestamp.timeAgoDisplay())
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal, 4)
            }
            
            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}

#Preview {
    ChatView(
        otherUserId: "user123",
        otherUserName: "Ali Hassan",
        currentUser: UserModel(
            name: "Ahmed",
            email: "ahmed@test.com",
            area: "Rawalpindi"
        ),
        postId: "post123",
        postTitle: "Honda City 2020"
    )
}