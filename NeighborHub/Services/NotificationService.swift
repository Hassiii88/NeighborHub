//
//  NotificationService.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging

class NotificationService {
    static let shared = NotificationService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: - Save FCM Token
    func saveFCMToken(_ token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.Collections.users)
            .document(uid)
            .updateData(["fcmToken": token]) { _ in }
    }
    
    // MARK: - Fetch Notifications
    func fetchNotifications(
        userId: String,
        completion: @escaping (Result<[NotificationModel], Error>) -> Void
    ) -> ListenerRegistration {
        let listener = db
            .collection(Constants.Collections.notifications)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 30)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let notifications = snapshot?.documents.compactMap {
                    try? $0.data(as: NotificationModel.self)
                } ?? []
                completion(.success(notifications))
            }
        return listener
    }
    
    // MARK: - Mark as Read
    func markAsRead(notificationId: String) {
        db.collection(Constants.Collections.notifications)
            .document(notificationId)
            .updateData(["isRead": true]) { _ in }
    }
    
    // MARK: - Mark All as Read
    func markAllAsRead(userId: String) {
        db.collection(Constants.Collections.notifications)
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    doc.reference.updateData(["isRead": true])
                }
            }
    }
    
    // MARK: - Create Notification
    func createNotification(_ notification: NotificationModel) {
        try? db
            .collection(Constants.Collections.notifications)
            .addDocument(from: notification)
    }
    
    // MARK: - Unread Count
    func fetchUnreadCount(
        userId: String,
        completion: @escaping (Int) -> Void
    ) -> ListenerRegistration {
        let listener = db
            .collection(Constants.Collections.notifications)
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { snapshot, _ in
                completion(snapshot?.documents.count ?? 0)
            }
        return listener
    }
}
