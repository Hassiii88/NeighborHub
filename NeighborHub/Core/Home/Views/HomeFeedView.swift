import SwiftUI

struct HomeFeedView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var postViewModel = PostViewModel()
    
    @State private var showAreaPicker: Bool = false
    @State private var showNotifications: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Top Bar
                    topBar
                    
                    // MARK: - Category Filter
                    categoryFilter
                        .padding(.top, 12)
                    
                    // MARK: - Posts Content
                    if postViewModel.isLoading && postViewModel.posts.isEmpty {
                        loadingView
                    } else if postViewModel.posts.isEmpty {
                        emptyView
                    } else {
                        postsList
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAreaPicker) {
                AreaPickerView(
                    selectedArea: Binding(
                        get: { postViewModel.selectedArea },
                        set: { postViewModel.filterByArea($0) }
                    )
                )
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
            .alert("Error", isPresented: $postViewModel.showError) {
                Button("OK") { postViewModel.showError = false }
            } message: {
                Text(postViewModel.errorMessage)
            }
            .onAppear {
                let area = authViewModel.currentUser?.area ?? ""
                postViewModel.fetchPosts(area: area)
                postViewModel.selectedArea = area
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("NeighborHub")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Button {
                    showAreaPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "E94560"))
                        
                        Text(postViewModel.selectedArea.isEmpty
                             ? "Select Area"
                             : postViewModel.selectedArea)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "E94560"))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "E94560"))
                    }
                }
            }
            
            Spacer()
            
            Button {
                showNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color(hex: "E94560"))
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
                .padding(10)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: postViewModel.selectedCategory == nil
                ) {
                    postViewModel.filterByCategory(nil)
                }
                
                ForEach(PostCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: postViewModel.selectedCategory == category
                    ) {
                        postViewModel.filterByCategory(category)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Posts List
    private var postsList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(postViewModel.posts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PostCardView(post: post)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .refreshable {
            postViewModel.fetchPosts(
                area: postViewModel.selectedArea,
                category: postViewModel.selectedCategory
            )
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .tint(Color(hex: "E94560"))
                .scaleEffect(1.3)
            
            Text("Loading posts...")
                .foregroundColor(.white.opacity(0.4))
                .font(.system(size: 14))
                .padding(.top, 12)
            
            Spacer()
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.2))
            
            Text("No posts available")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Create a post or change your area filter")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    HomeFeedView()
        .environmentObject(AuthViewModel())
}
