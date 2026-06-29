//
//  PostViewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore
import Combine

class PostViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var posts: [PostModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var selectedCategory: PostCategory? = nil
    @Published var selectedArea: String = ""
    
    // MARK: - Private
    private var listener: ListenerRegistration?
    
    // MARK: - Init
    init() {}
    
    // MARK: - Fetch Posts
    func fetchPosts(area: String = "", category: PostCategory? = nil) {
        isLoading = true
        
        // Old listener remove karo
        listener?.remove()
        
        listener = PostService.shared.fetchPosts(
            area: area.isEmpty ? nil : area,
            category: category
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let posts):
                    self.posts = posts
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Filter by Category
    func filterByCategory(_ category: PostCategory?) {
        selectedCategory = category
        fetchPosts(area: selectedArea, category: category)
    }
    
    // MARK: - Filter by Area
    func filterByArea(_ area: String) {
        selectedArea = area
        fetchPosts(area: area, category: selectedCategory)
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
    
    // MARK: - Deinit
    deinit {
        listener?.remove()
    }
}