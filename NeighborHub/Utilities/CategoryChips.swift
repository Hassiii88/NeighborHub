//
//  CategoryChip.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//

import SwiftUI


// MARK: - Category Chip
struct CategoryChips: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? Color(hex: "E94560")
                : Color.white.opacity(0.07)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected
                        ? Color.clear
                        : Color.white.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Post Card View
struct PostCardView: View {
    var post: PostModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Image
            if let imageURL = post.imageURLs.first,
               !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.05))
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(height: 180)
                .clipped()
            } else {
                placeholderImage
            }
            
            // MARK: - Content
            VStack(alignment: .leading, spacing: 8) {
                
                // Category Badge + Time
                HStack {
                    Label(post.category.rawValue, systemImage: post.category.icon)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "E94560"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "E94560").opacity(0.12))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text(post.createdAt.timeAgoDisplay())
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.35))
                }
                
                // Title
                Text(post.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Price + Area
                HStack {
                    Text(post.price.formattedPrice())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "E94560"))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                        Text(post.area)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.35))
                }
                
                // Seller Info
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: "E94560").opacity(0.2))
                        .frame(width: 26, height: 26)
                        .overlay(
                            Text(String(post.userName.prefix(1)).uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "E94560"))
                        )
                    
                    Text(post.userName)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(14)
        }
        .background(Color(hex: "16213E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color(hex: "16213E")
            Image(systemName: post.category.icon)
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "E94560").opacity(0.3))
        }
        .frame(height: 180)
    }
}

