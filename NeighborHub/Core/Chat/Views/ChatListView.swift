//
//  ChatListView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import SwiftUI
import Combine
struct ChatListView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - Content
                    if chatViewModel.isLoading {
                        loadingView
                    } else if chatViewModel.chats.isEmpty {
                        emptyView
                    } else {
                        chatsList
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $chatViewModel.showError) {
                Button("OK") { chatViewModel.showError = false }
            } message: {
                Text(chatViewModel.errorMessage)
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    chatViewModel.fetchChats(userId: userId)
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Messages")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(chatViewModel.chats.count) conversations")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            
            // Message icon
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "E94560"))
                .padding(10)
                .background(Color(hex: "E94560").opacity(0.12))
                .clipShape(Circle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Chats List
    private var chatsList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(chatViewModel.chats) { chat in
                    if let currentUser = authViewModel.currentUser,
                       let currentUserId = currentUser.id {
                        
                        let otherUserName = chatViewModel.getOtherUserName(
                            chat: chat,
                            currentUserId: currentUserId
                        )
                        
                        NavigationLink(destination:
                            ChatView(
                                otherUserId: chat.participants.first(where: { $0 != currentUserId }) ?? "",
                                otherUserName: otherUserName,
                                currentUser: currentUser,
                                postId: chat.postId,
                                postTitle: chat.postTitle
                            )
                        ) {
                            ChatRowView(
                                chat: chat,
                                otherUserName: otherUserName,
                                currentUserId: currentUserId
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Loading
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Color(hex: "E94560"))
                .scaleEffect(1.3)
            Spacer()
        }
    }
    
    // MARK: - Empty
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "E94560").opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No Messages Yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Start a conversation by\ntapping on any post")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
}

// MARK: - Chat Row View
struct ChatRowView: View {
    var chat: ChatModel
    var otherUserName: String
    var currentUserId: String
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.15))
                    .frame(width: 54, height: 54)
                
                Text(String(otherUserName.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "E94560"))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(otherUserName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(chat.lastMessageTime.timeAgoDisplay())
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.35))
                }
                
                HStack {
                    // Post title
                    Text(chat.postTitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "E94560"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "E94560").opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Unread badge
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Color(hex: "E94560"))
                            .clipShape(Circle())
                    }
                }
                
                Text(chat.lastMessage.isEmpty ? "Start the conversation..." : chat.lastMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(hex: "16213E").opacity(0.5))
        .overlay(
            Divider()
                .background(Color.white.opacity(0.06)),
            alignment: .bottom
        )
    }
}

#Preview {
    ChatListView()
        .environmentObject(AuthViewModel())
}
