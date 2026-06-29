//
//  PostService.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class PostService {
    static let shared = PostService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: - Fetch All Posts (Real-time)
    func fetchPosts(
        area: String? = nil,
        category: PostCategory? = nil,
        completion: @escaping (Result<[PostModel], Error>) -> Void
    ) -> ListenerRegistration {
        
        var query: Query = db
            .collection(Constants.Collections.posts)
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .limit(to: 30)
        
        if let area = area, !area.isEmpty {
            query = query.whereField("area", isEqualTo: area)
        }
        
        if let category = category {
            query = query.whereField("category", isEqualTo: category.rawValue)
        }
        
        let listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let posts = documents.compactMap { doc -> PostModel? in
                try? doc.data(as: PostModel.self)
            }
            
            completion(.success(posts))
        }
        
        return listener
    }
    
    // MARK: - Fetch Single Post
    func fetchPost(
        postId: String,
        completion: @escaping (Result<PostModel, Error>) -> Void
    ) {
        db.collection(Constants.Collections.posts)
            .document(postId)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                do {
                    let post = try snapshot?.data(as: PostModel.self)
                    if let post = post {
                        completion(.success(post))
                    } else {
                        completion(.failure(PostError.notFound))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Fetch My Posts
    func fetchMyPosts(
        userId: String,
        completion: @escaping (Result<[PostModel], Error>) -> Void
    ) -> ListenerRegistration {
        
        let listener = db
            .collection(Constants.Collections.posts)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let posts = snapshot?.documents.compactMap {
                    try? $0.data(as: PostModel.self)
                } ?? []
                
                completion(.success(posts))
            }
        
        return listener
    }
    
    // MARK: - Create Post
    func createPost(
        _ post: PostModel,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        do {
            let ref = try db
                .collection(Constants.Collections.posts)
                .addDocument(from: post)
            
            completion(.success(ref.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Delete Post (Soft Delete)
    func deletePost(
        postId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(Constants.Collections.posts)
            .document(postId)
            .updateData(["isActive": false]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Search Posts
    func searchPosts(
        query: String,
        completion: @escaping (Result<[PostModel], Error>) -> Void
    ) {
        db.collection(Constants.Collections.posts)
            .whereField("isActive", isEqualTo: true)
            .order(by: "title")
            .start(at: [query])
            .end(at: [query + "\u{f8ff}"])
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let posts = snapshot?.documents.compactMap {
                    try? $0.data(as: PostModel.self)
                } ?? []
                
                completion(.success(posts))
            }
    }
}

// MARK: - Post Errors
enum PostError: LocalizedError {
    case notFound
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Post not found"
        case .permissionDenied:
            return "You do not have permission to perform this action"
        }
    }
}
