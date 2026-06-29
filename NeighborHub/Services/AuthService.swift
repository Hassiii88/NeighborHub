//
//  AuthService.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    // MARK: - Current User
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    // MARK: - Register
    func register(
        name: String,
        email: String,
        password: String,
        area: String,
        completion: @escaping (Result<UserModel, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(AuthError.noUID))
                return
            }
            
            // Firestore mein user save karo
            let user = UserModel(id: uid, name: name, email: email, area: area)
            
            do {
                try self.db
                    .collection(Constants.Collections.users)
                    .document(uid)
                    .setData(from: user) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(user))
                        }
                    }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Login
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<UserModel, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let uid = result?.user.uid else {
                completion(.failure(AuthError.noUID))
                return
            }
            
            // Firestore se user data fetch karo
            self.fetchUser(uid: uid, completion: completion)
        }
    }
    
    // MARK: - Fetch User
    func fetchUser(
        uid: String,
        completion: @escaping (Result<UserModel, Error>) -> Void
    ) {
        db.collection(Constants.Collections.users)
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(.failure(AuthError.userNotFound))
                    return
                }
                
                do {
                    let user = try snapshot.data(as: UserModel.self)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(
        uid: String,
        name: String,
        area: String,
        profileImageURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(Constants.Collections.users)
            .document(uid)
            .updateData([
                "name": name,
                "area": area,
                "profileImageURL": profileImageURL
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case noUID
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .noUID:        return "User ID nahi mila"
        case .userNotFound: return "User account nahi mila"
        }
    }
}