//
//  UserProfileView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import SwiftUI
import Combine
struct UserProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var userViewModel = UserViewModel()
    
    @State private var showEditProfile: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var showSignOutAlert: Bool = false
    @State private var showMyPosts: Bool = false
    @State private var showReviews: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                if userViewModel.isLoading {
                    loadingView
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            
                            // MARK: - Header Background
                            headerBackground
                            
                            // MARK: - Profile Card
                            profileCard
                                .offset(y: -50)
                                .padding(.bottom, -50)
                            
                            // MARK: - Stats Row
                            statsRow
                                .padding(.top, 20)
                            
                            // MARK: - Menu Items
                            menuSection
                                .padding(.top, 24)
                            
                            // MARK: - Sign Out
                            signOutButton
                                .padding(.top, 16)
                                .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(userViewModel: userViewModel)
            }
            .sheet(isPresented: $showMyPosts) {
                MyPostsView(userViewModel: userViewModel)
            }
            .sheet(isPresented: $showReviews) {
                ReviewsView(reviews: userViewModel.reviews)
            }
            .alert("Sign Out?", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Error", isPresented: $userViewModel.showError) {
                Button("OK") { userViewModel.showError = false }
            } message: {
                Text(userViewModel.errorMessage)
            }
            .alert("Success", isPresented: $userViewModel.showSuccess) {
                Button("OK") { userViewModel.showSuccess = false }
            } message: {
                Text(userViewModel.successMessage)
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    userViewModel.fetchUserProfile(userId: userId)
                }
            }
        }
    }
    
    // MARK: - Header Background
    private var headerBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E94560").opacity(0.6), Color(hex: "1A1A2E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 180)
            
            // Edit button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
            .frame(height: 180)
        }
    }
    
    // MARK: - Profile Card
    private var profileCard: some View {
        VStack(spacing: 12) {
            
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color(hex: "16213E"))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "E94560"), lineWidth: 3)
                    )
                
                if let imageURL = userViewModel.user?.profileImageURL,
                   !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView().tint(Color(hex: "E94560"))
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                } else {
                    Text(String(
                        (userViewModel.user?.name ?? "U").prefix(1)
                    ).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "E94560"))
                }
            }
            
            // Name
            Text(userViewModel.user?.name ?? "")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            // Email
            Text(userViewModel.user?.email ?? "")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
            
            // Area Badge
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11))
                Text(userViewModel.user?.area ?? "")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(Color(hex: "E94560"))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color(hex: "E94560").opacity(0.12))
            .cornerRadius(20)
            
            // Rating Stars
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(userViewModel.averageRating)
                          ? "star.fill" : "star")
                        .font(.system(size: 14))
                        .foregroundColor(
                            star <= Int(userViewModel.averageRating)
                            ? Color.yellow
                            : Color.white.opacity(0.2)
                        )
                }
                Text(String(format: "%.1f", userViewModel.averageRating))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.leading, 4)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            
            StatItemView(
                value: "\(userViewModel.activePosts)",
                label: "Active Posts"
            )
            
            Divider()
                .background(Color.white.opacity(0.1))
                .frame(height: 40)
            
            StatItemView(
                value: "\(userViewModel.totalReviews)",
                label: "Reviews"
            )
            
            Divider()
                .background(Color.white.opacity(0.1))
                .frame(height: 40)
            
            StatItemView(
                value: String(format: "%.1f", userViewModel.averageRating),
                label: "Rating"
            )
        }
        .padding(.vertical, 16)
        .background(Color(hex: "16213E"))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: 2) {
            ProfileMenuItem(
                icon: "square.grid.2x2.fill",
                title: "My Posts",
                subtitle: "\(userViewModel.myPosts.count) total posts",
                color: Color(hex: "E94560")
            ) {
                showMyPosts = true
            }
            
            ProfileMenuItem(
                icon: "star.fill",
                title: "My Reviews",
                subtitle: "\(userViewModel.totalReviews) reviews received",
                color: Color.yellow
            ) {
                showReviews = true
            }
            
            ProfileMenuItem(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: "Manage your alerts",
                color: Color.blue
            ) {
                // Navigate to notifications
            }
            
            ProfileMenuItem(
                icon: "shield.fill",
                title: "Privacy & Safety",
                subtitle: "Control your data",
                color: Color.green
            ) {
                // Navigate to privacy
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button {
            showSignOutAlert = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(Color(hex: "E94560"))
                Text("Sign Out")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "E94560"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(hex: "E94560").opacity(0.1))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "E94560").opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Color(hex: "E94560"))
                .scaleEffect(1.3)
            Spacer()
        }
    }
}

// MARK: - Stat Item View
struct StatItemView: View {
    var value: String
    var label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    var icon: String
    var title: String
    var subtitle: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(hex: "16213E"))
            .cornerRadius(14)
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    UserProfileView()
        .environmentObject(AuthViewModel())
}
