//
//  UserViewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
class UserViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var user: UserModel?
    @Published var myPosts: [PostModel] = []
    @Published var reviews: [ReviewModel] = []
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var showSuccess: Bool = false
    @Published var successMessage: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var isUploadingImage: Bool = false
    
    // MARK: - Private
    private var postsListener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // MARK: - Fetch User Profile
    func fetchUserProfile(userId: String) {
        isLoading = true
        AuthService.shared.fetchUser(uid: userId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.user = user
                    self.fetchMyPosts(userId: userId)
                    self.fetchReviews(userId: userId)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Fetch My Posts
    func fetchMyPosts(userId: String) {
        postsListener?.remove()
        postsListener = PostService.shared.fetchMyPosts(userId: userId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.myPosts = posts
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Fetch Reviews
    func fetchReviews(userId: String) {
        db.collection(Constants.Collections.reviews)
            .whereField("reviewedUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.reviews = snapshot?.documents.compactMap {
                        try? $0.data(as: ReviewModel.self)
                    } ?? []
                }
            }
    }
    
    // MARK: - Update Profile with Image
    func updateProfile(
        userId: String,
        name: String,
        area: String
    ) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Name cannot be empty"
            showError = true
            return
        }
        
        isUpdating = true
        
        // Image selected hai to pehle upload karo
        if let image = selectedImage {
            isUploadingImage = true
            StorageService.shared.uploadImage(
                image,
                folder: "neighborrhub/profiles"
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let imageURL):
                    self.isUploadingImage = false
                    self.saveProfile(
                        userId: userId,
                        name: name,
                        area: area,
                        imageURL: imageURL
                    )
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isUpdating = false
                        self.isUploadingImage = false
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    }
                }
            }
        } else {
            // No image — direct save
            saveProfile(
                userId: userId,
                name: name,
                area: area,
                imageURL: user?.profileImageURL ?? ""
            )
        }
    }
    
    // MARK: - Save Profile to Firestore
    private func saveProfile(
        userId: String,
        name: String,
        area: String,
        imageURL: String
    ) {
        AuthService.shared.updateProfile(
            uid: userId,
            name: name,
            area: area,
            profileImageURL: imageURL
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isUpdating = false
                switch result {
                case .success:
                    self.user?.name = name
                    self.user?.area = area
                    self.user?.profileImageURL = imageURL
                    self.successMessage = "Profile updated successfully!"
                    self.showSuccess = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Delete Post
    func deletePost(postId: String) {
        PostService.shared.deletePost(postId: postId) { [weak self] result in
            guard let self = self else { return }
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Computed Stats
    var activePosts: Int {
        myPosts.filter { $0.isActive }.count
    }
    
    var averageRating: Double {
        user?.rating ?? 0.0
    }
    
    var totalReviews: Int {
        reviews.count
    }
    
    // MARK: - Deinit
    deinit {
        postsListener?.remove()
    }
}
