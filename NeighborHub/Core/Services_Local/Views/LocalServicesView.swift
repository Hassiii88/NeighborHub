//
//  LocalServicesView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import SwiftUI

struct LocalServicesView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var postViewModel = PostViewModel()
    @State private var selectedService: LocalServiceType = .all
    
    enum LocalServiceType: String, CaseIterable {
        case all = "All Services"
        case plumber = "Plumber"
        case electrician = "Electrician"
        case carpenter = "Carpenter"
        case painter = "Painter"
        case mechanic = "Mechanic"
        case tutor = "Tutor"
        case doctor = "Doctor"
        case cleaner = "Cleaner"
        
        var icon: String {
            switch self {
            case .all:          return "square.grid.2x2.fill"
            case .plumber:      return "drop.fill"
            case .electrician:  return "bolt.fill"
            case .carpenter:    return "hammer.fill"
            case .painter:      return "paintbrush.fill"
            case .mechanic:     return "wrench.fill"
            case .tutor:        return "book.fill"
            case .doctor:       return "cross.fill"
            case .cleaner:      return "sparkles"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - Service Types Grid
                    serviceTypesGrid
                        .padding(.top, 12)
                    
                    // MARK: - Services List
                    if postViewModel.isLoading {
                        loadingView
                    } else if postViewModel.posts.isEmpty {
                        emptyView
                    } else {
                        servicesList
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                postViewModel.fetchPosts(
                    area: authViewModel.currentUser?.area ?? "",
                    category: .service
                )
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Local Services")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Find trusted professionals near you")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Service Types Grid
    private var serviceTypesGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LocalServiceType.allCases, id: \.self) { service in
                        Button {
                            selectedService = service
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            selectedService == service
                                            ? Color(hex: "E94560")
                                            : Color(hex: "E94560").opacity(0.1)
                                        )
                                        .frame(width: 52, height: 52)
                                    
                                    Image(systemName: service.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(
                                            selectedService == service
                                            ? .white
                                            : Color(hex: "E94560")
                                        )
                                }
                                
                                Text(service.rawValue
                                    .components(separatedBy: " ")
                                    .last ?? service.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(
                                        selectedService == service
                                        ? Color(hex: "E94560")
                                        : .white.opacity(0.5)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Services List
    private var servicesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredPosts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        ServiceCardView(post: post)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Filtered Posts
    var filteredPosts: [PostModel] {
        if selectedService == .all {
            return postViewModel.posts
        }
        return postViewModel.posts.filter {
            $0.title.lowercased().contains(selectedService.rawValue.lowercased()) ||
            $0.description.lowercased().contains(selectedService.rawValue.lowercased())
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView().tint(Color(hex: "E94560"))
            Spacer()
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.2))
            Text("No services available")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            Text("Check back later or post your own service")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Service Card View
struct ServiceCardView: View {
    var post: PostModel
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Service Icon or Image
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "E94560").opacity(0.1))
                    .frame(width: 70, height: 70)
                
                if let url = post.imageURLs.first, !url.isEmpty {
                    AsyncImage(url: URL(string: url)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView().tint(Color(hex: "E94560"))
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(14)
                    .clipped()
                } else {
                    Image(systemName: "wrench.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "E94560"))
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(post.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(post.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(2)
                
                HStack(spacing: 10) {
                    Text(post.price.formattedPrice())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "E94560"))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(post.area)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.2))
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
    LocalServicesView()
        .environmentObject(AuthViewModel())
}
