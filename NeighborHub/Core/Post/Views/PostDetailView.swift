//
//  PostDetailView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


//
//  PostDetailView.swift
//  NeighborHub
//

import SwiftUI

struct PostDetailView: View {
    
    var post: PostModel
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showChat: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var currentImageIndex: Int = 0
    
    var isMyPost: Bool {
        post.userId == authViewModel.currentUser?.id
    }
    
    var body: some View {
        ZStack {
            Color(hex: "1A1A2E").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    imageSection
                    
                    VStack(alignment: .leading, spacing: 20) {
                        titleSection
                        priceSection
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        descriptionSection
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        locationSection
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        sellerSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
            }
            
            VStack {
                Spacer()
                bottomButton
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            topBar
        }
        .alert("Delete Post?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let id = post.id {
                    PostService.shared.deletePost(postId: id) { _ in }
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This post will be permanently deleted.")
        }
        .fullScreenCover(isPresented: $showChat) {
            // FIX: ChatView was missing → replace or keep commented safely
            // ChatView(...)
            Text("Chat Screen Missing")
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            if isMyPost {
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 52)
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        ZStack(alignment: .bottom) {
            if post.imageURLs.isEmpty {
                ZStack {
                    Color(hex: "16213E")
                    Image(systemName: post.category.icon)
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "E94560").opacity(0.3))
                }
                .frame(height: 280)
            } else {
                TabView(selection: $currentImageIndex) {
                    ForEach(post.imageURLs.indices, id: \.self) { index in
                        AsyncImage(url: URL(string: post.imageURLs[index])) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .empty:
                                ProgressView()
                            default:
                                Color.gray
                            }
                        }
                        .frame(height: 280)
                        .clipped()
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 280)
            }
        }
    }
    
    // MARK: - Title
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(post.category.rawValue, systemImage: post.category.icon)
                    .foregroundColor(Color(hex: "E94560"))
                
                Spacer()
                
                Text(post.createdAt.timeAgoDisplay())
                    .foregroundColor(.white.opacity(0.35))
            }
            
            Text(post.title)
                .font(.title2.bold())
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Price
    private var priceSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Price")
                    .foregroundColor(.white.opacity(0.4))
                
                Text(post.price.formattedPrice())
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "E94560"))
            }
            
            Spacer()
            
            if post.isActive {
                Text("Active")
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Description
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .foregroundColor(.white.opacity(0.6))
            
            Text(post.description)
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    // MARK: - Location
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .foregroundColor(.white.opacity(0.6))
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(Color(hex: "E94560"))
                
                Text(post.area)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Seller
    private var sellerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Seller")
                .foregroundColor(.white.opacity(0.6))
            
            HStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.2))
                    .frame(width: 45, height: 45)
                    .overlay(
                        Text(String(post.userName.prefix(1)))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(post.userName)
                        .foregroundColor(.white)
                    Text(post.area)
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        VStack {
            Divider().background(Color.white.opacity(0.1))
            
            Button {
                if isMyPost {
                    // edit action
                } else {
                    showChat = true
                }
            } label: {
                Text(isMyPost ? "Edit Post" : "Chat with Seller")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "E94560"))
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
        }
        .background(Color(hex: "1A1A2E"))
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: PostModel(
            title: "Honda City 2020",
            description: "Condition All Okay..",
            category: .sell,
            price: 3500000,
            userId: "123",
            userName: "Ali Hassan",
            area: "Rawalpindi",
            latitude: 33.6007,
            longitude: 73.0679
        ))
        .environmentObject(AuthViewModel())
    }
}
