//
//  ReviewsView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import SwiftUI

struct ReviewsView: View {
    
    var reviews: [ReviewModel]
    @Environment(\.dismiss) var dismiss
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Rating Summary
                    ratingSummary
                        .padding(.vertical, 20)
                    
                    Divider()
                        .background(Color.white.opacity(0.08))
                    
                    // Reviews List
                    if reviews.isEmpty {
                        emptyView
                    } else {
                        reviewsList
                    }
                }
            }
            .navigationTitle("Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "E94560"))
                }
            }
            .toolbarBackground(Color(hex: "16213E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    // MARK: - Rating Summary
    private var ratingSummary: some View {
        VStack(spacing: 10) {
            Text(String(format: "%.1f", averageRating))
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 6) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(averageRating) ? "star.fill" : "star")
                        .font(.system(size: 20))
                        .foregroundColor(
                            star <= Int(averageRating)
                            ? Color.yellow
                            : Color.white.opacity(0.2)
                        )
                }
            }
            
            Text("\(reviews.count) total reviews")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
        }
    }
    
    // MARK: - Reviews List
    private var reviewsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(reviews) { review in
                    ReviewRowView(review: review)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "star.slash")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.2))
            Text("No reviews yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
        }
    }
}

// MARK: - Review Row View
struct ReviewRowView: View {
    var review: ReviewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: "E94560").opacity(0.15))
                        .frame(width: 40, height: 40)
                    Text(String(review.reviewerName.prefix(1)).uppercased())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(hex: "E94560"))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(review.reviewerName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 3) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                .font(.system(size: 11))
                                .foregroundColor(
                                    star <= review.rating
                                    ? Color.yellow
                                    : Color.white.opacity(0.2)
                                )
                        }
                    }
                }
                
                Spacer()
                
                Text(review.createdAt.timeAgoDisplay())
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(Color(hex: "16213E"))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}