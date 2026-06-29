//
//  NotificationsView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import SwiftUI
import FirebaseFirestore

struct NotificationsView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var notifications: [NotificationModel] = []
    @State private var isLoading: Bool = true
    @State private var listener: ListenerRegistration?
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - Content
                    if isLoading {
                        loadingView
                    } else if notifications.isEmpty {
                        emptyView
                    } else {
                        notificationsList
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { fetchNotifications() }
            .onDisappear { listener?.remove() }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Notifications")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                if unreadCount > 0 {
                    Text("\(unreadCount) unread")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "E94560"))
                }
            }
            
            Spacer()
            
            if unreadCount > 0 {
                Button {
                    markAllRead()
                } label: {
                    Text("Mark all read")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "E94560"))
                }
            } else {
                // Spacer to center title
                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "16213E"))
        .overlay(
            Divider()
                .background(Color.white.opacity(0.08)),
            alignment: .bottom
        )
    }
    
    // MARK: - Notifications List
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(notifications) { notification in
                    NotificationRowView(notification: notification) {
                        NotificationService.shared.markAsRead(
                            notificationId: notification.id ?? ""
                        )
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Loading
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView().tint(Color(hex: "E94560"))
            Spacer()
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "bell.slash")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "E94560").opacity(0.5))
            }
            VStack(spacing: 8) {
                Text("No Notifications")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("You're all caught up!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
    }
    
    // MARK: - Fetch Notifications
    private func fetchNotifications() {
        guard let userId = authViewModel.currentUser?.id else { return }
        isLoading = true
        listener = NotificationService.shared.fetchNotifications(
            userId: userId
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .success(let items) = result {
                    notifications = items
                }
            }
        }
    }
    
    // MARK: - Mark All Read
    private func markAllRead() {
        guard let userId = authViewModel.currentUser?.id else { return }
        NotificationService.shared.markAllAsRead(userId: userId)
    }
}

// MARK: - Notification Row
struct NotificationRowView: View {
    var notification: NotificationModel
    var onTap: () -> Void
    
    var notifColor: Color {
        switch notification.type {
        case .newMessage:    return Color.blue
        case .newReview:     return Color.yellow
        case .emergency:     return Color(hex: "E94560")
        case .eventReminder: return Color.green
        case .postInterest:  return Color.purple
        }
    }
    
    var notifIcon: String {
        switch notification.type {
        case .newMessage:    return "message.fill"
        case .newReview:     return "star.fill"
        case .emergency:     return "exclamationmark.triangle.fill"
        case .eventReminder: return "calendar"
        case .postInterest:  return "tag.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                
                // Icon
                ZStack {
                    Circle()
                        .fill(notifColor.opacity(0.15))
                        .frame(width: 46, height: 46)
                    Image(systemName: notifIcon)
                        .font(.system(size: 18))
                        .foregroundColor(notifColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 15, weight: notification.isRead ? .regular : .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(notification.body)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                    
                    Text(notification.createdAt.timeAgoDisplay())
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                }
                
                Spacer()
                
                // Unread dot
                if !notification.isRead {
                    Circle()
                        .fill(Color(hex: "E94560"))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                notification.isRead
                ? Color.clear
                : Color(hex: "E94560").opacity(0.04)
            )
        }
        .overlay(
            Divider()
                .background(Color.white.opacity(0.06)),
            alignment: .bottom
        )
    }
}

#Preview {
    NotificationsView()
        .environmentObject(AuthViewModel())
}
