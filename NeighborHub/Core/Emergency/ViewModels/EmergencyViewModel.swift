//
//  EmergencyViewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import Foundation
import FirebaseFirestore
import Combine
class EmergencyViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var emergencyPosts: [PostModel] = []
    @Published var selectedType: EmergencyType = .medical
    @Published var description: String = ""
    @Published var isSending: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private
    private var listener: ListenerRegistration?
    
    // MARK: - Fetch Emergency Posts
    func fetchEmergencyPosts() {
        listener?.remove()
        listener = PostService.shared.fetchPosts(
            area: nil,
            category: .emergency
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if case .success(let posts) = result {
                    self.emergencyPosts = posts
                }
            }
        }
    }
    
    // MARK: - Send Emergency Alert
    func sendEmergencyAlert(user: UserModel?) {
        guard let user = user, let userId = user.id else { return }
        
        isSending = true
        
        let post = PostModel(
            title: "\(selectedType.title) Emergency - \(user.area)",
            description: description.isEmpty
                ? "Emergency alert from \(user.name) in \(user.area)"
                : description,
            category: .emergency,
            price: 0,
            userId: userId,
            userName: user.name,
            area: user.area
        )
        
        PostService.shared.createPost(post) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSending = false
                switch result {
                case .success:
                    self.showSuccess = true
                    self.description = ""
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Deinit
    deinit {
        listener?.remove()
    }
}
