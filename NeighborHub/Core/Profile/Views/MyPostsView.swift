//
//  MyPostsView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import SwiftUI

struct MyPostsView: View {
    
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert: Bool = false
    @State private var postToDelete: String? = nil
    @State private var selectedFilter: PostFilter = .all
    
    enum PostFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case inactive = "Inactive"
    }
    
    var filteredPosts: [PostModel] {
        switch selectedFilter {
        case .all:      return userViewModel.myPosts
        case .active:   return userViewModel.myPosts.filter { $0.isActive }
        case .inactive: return userViewModel.myPosts.filter { !$0.isActive }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - Filter
                    filterView
                        .padding(.top, 12)
                    
                    // MARK: - Posts
                    if filteredPosts.isEmpty {
                        emptyView
                    } else {
                        postsList
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Delete Post?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let id = postToDelete {
                        userViewModel.deletePost(postId: id)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This post will be permanently removed.")
            }
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
            
            Text("My Posts")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(userViewModel.myPosts.count)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "E94560"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "E94560").opacity(0.12))
                .cornerRadius(20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Filter
    private var filterView: some View {
        HStack(spacing: 8) {
            ForEach(PostFilter.allCases, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(
                            selectedFilter == filter
                            ? .white
                            : .white.opacity(0.4)
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedFilter == filter
                            ? Color(hex: "E94560")
                            : Color.white.opacity(0.07)
                        )
                        .cornerRadius(20)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Posts List
    private var postsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredPosts) { post in
                    MyPostRowView(post: post) {
                        postToDelete = post.id
                        showDeleteAlert = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.2))
            Text("No posts found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
        }
    }
}

// MARK: - My Post Row View
struct MyPostRowView: View {
    var post: PostModel
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Image or Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "16213E"))
                    .frame(width: 70, height: 70)
                
                if let imageURL = post.imageURLs.first, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView().tint(Color(hex: "E94560"))
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(12)
                    .clipped()
                } else {
                    Image(systemName: post.category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "E94560").opacity(0.6))
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(post.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(post.price.formattedPrice())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "E94560"))
                
                HStack(spacing: 6) {
                    // Status badge
                    Text(post.isActive ? "Active" : "Inactive")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(post.isActive ? Color.green : Color.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            post.isActive
                            ? Color.green.opacity(0.12)
                            : Color.gray.opacity(0.12)
                        )
                        .cornerRadius(6)
                    
                    Text(post.createdAt.timeAgoDisplay())
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Spacer()
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "E94560"))
                    .padding(10)
                    .background(Color(hex: "E94560").opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(14)
        .background(Color(hex: "16213E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}

#Preview {
    MyPostsView(userViewModel: UserViewModel())
}