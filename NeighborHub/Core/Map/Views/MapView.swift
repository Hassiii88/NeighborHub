//
//  MapView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import SwiftUI
import MapKit
import Combine
struct MapView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var mapViewModel = MapViewModel()
    @State private var showPostDetail: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // MARK: - Map
                Map(
                    coordinateRegion: $mapViewModel.region,
                    showsUserLocation: true,
                    annotationItems: mapViewModel.posts
                ) { post in
                    MapAnnotation(
                        coordinate: CLLocationCoordinate2D(
                            latitude: post.latitude,
                            longitude: post.longitude
                        )
                    ) {
                        PostMapPin(
                            post: post,
                            isSelected: mapViewModel.selectedPost?.id == post.id
                        ) {
                            withAnimation(.spring()) {
                                mapViewModel.selectedPost = post
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                
                // MARK: - Top Overlay
                VStack {
                    topOverlay
                    Spacer()
                    
                    // Selected Post Card
                    if let post = mapViewModel.selectedPost {
                        selectedPostCard(post: post)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 90)
                    }
                }
                
                // MARK: - Location Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        locationButton
                            .padding(.trailing, 20)
                            .padding(.bottom, mapViewModel.selectedPost != nil ? 200 : 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(
                "Location Access Required",
                isPresented: $mapViewModel.locationPermissionDenied
            ) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location in Settings to see nearby posts.")
            }
            .onAppear {
                mapViewModel.fetchMapPosts()
            }
            .navigationDestination(isPresented: $showPostDetail) {
                if let post = mapViewModel.selectedPost {
                    PostDetailView(post: post)
                }
            }
        }
    }
    
    // MARK: - Top Overlay
    private var topOverlay: some View {
        VStack(spacing: 10) {
            
            // Title bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nearby Posts")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(mapViewModel.posts.count) Posts on map")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                
                // Loading indicator
                if mapViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [Color(hex: "1A1A2E"), Color(hex: "1A1A2E").opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CategoryChip(
                        title: "All",
                        icon: "square.grid.2x2.fill",
                        isSelected: mapViewModel.selectedCategory == nil
                    ) {
                        mapViewModel.filterByCategory(nil)
                    }
                    
                    ForEach(PostCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: mapViewModel.selectedCategory == category
                        ) {
                            mapViewModel.filterByCategory(category)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Selected Post Card
    private func selectedPostCard(post: PostModel) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                
                // Image or Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "1A1A2E"))
                        .frame(width: 60, height: 60)
                    
                    if let url = post.imageURLs.first, !url.isEmpty {
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView().tint(Color(hex: "E94560"))
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                        .clipped()
                    } else {
                        Image(systemName: post.category.icon)
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "E94560"))
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 5) {
                    Text(post.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(post.price.formattedPrice())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "E94560"))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(post.area)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // View Button
                Button {
                    showPostDetail = true
                } label: {
                    Text("View")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(hex: "E94560"))
                        .cornerRadius(10)
                }
            }
            .padding(16)
        }
        .background(Color(hex: "16213E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .shadow(color: Color.black.opacity(0.3), radius: 10)
        .onTapGesture {
            withAnimation {
                mapViewModel.selectedPost = nil
            }
        }
    }
    
    // MARK: - Location Button
    private var locationButton: some View {
        Button {
            withAnimation {
                if let location = mapViewModel.userLocation {
                    mapViewModel.region = MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.03,
                            longitudeDelta: 0.03
                        )
                    )
                }
            }
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "E94560"))
                .frame(width: 46, height: 46)
                .background(Color(hex: "16213E"))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

// MARK: - Post Map Pin
struct PostMapPin: View {
    var post: PostModel
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(hex: "E94560") : Color(hex: "16213E"))
                        .frame(
                            width: isSelected ? 44 : 36,
                            height: isSelected ? 44 : 36
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    Color(hex: "E94560"),
                                    lineWidth: isSelected ? 0 : 2
                                )
                        )
                        .shadow(
                            color: Color(hex: "E94560").opacity(isSelected ? 0.5 : 0.2),
                            radius: isSelected ? 8 : 4
                        )
                    
                    Image(systemName: post.category.icon)
                        .font(.system(size: isSelected ? 16 : 13))
                        .foregroundColor(
                            isSelected ? .white : Color(hex: "E94560")
                        )
                }
                
                // Pin tail
                Triangle()
                    .fill(isSelected ? Color(hex: "E94560") : Color(hex: "16213E"))
                    .frame(width: 10, height: 6)
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Triangle Shape for pin
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    MapView()
        .environmentObject(AuthViewModel())
}
