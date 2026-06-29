//
//  SearchView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var searchViewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - Search Bar
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    
                    // MARK: - Filter Row
                    filterRow
                    
                    // MARK: - Content
                    if searchViewModel.searchText.isEmpty {
                        recentSearches
                    } else if searchViewModel.isLoading {
                        loadingView
                    } else if searchViewModel.results.isEmpty {
                        noResultsView
                    } else {
                        resultsList
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Discover")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Find anything near you")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchViewModel.searchText.isEmpty
                    ? .white.opacity(0.3)
                    : Color(hex: "E94560")
                )
                .font(.system(size: 16))
            
            TextField("", text: $searchViewModel.searchText)
                .placeholder(when: searchViewModel.searchText.isEmpty) {
                    Text("Search posts, services...")
                        .foregroundColor(.white.opacity(0.3))
                }
                .foregroundColor(.white)
                .tint(Color(hex: "E94560"))
                .onChange(of: searchViewModel.searchText) { _ in
                    searchViewModel.performSearch()
                }
            
            if !searchViewModel.searchText.isEmpty {
                Button {
                    searchViewModel.searchText = ""
                    searchViewModel.results = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.07))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    searchViewModel.searchText.isEmpty
                    ? Color.white.opacity(0.1)
                    : Color(hex: "E94560").opacity(0.4),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Filter Row
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: searchViewModel.selectedCategory == nil
                ) {
                    searchViewModel.selectedCategory = nil
                    searchViewModel.performSearch()
                }
                
                ForEach(PostCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: searchViewModel.selectedCategory == category
                    ) {
                        searchViewModel.selectedCategory = category
                        searchViewModel.performSearch()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Recent Searches
    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            if !searchViewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Searches")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Button("Clear") {
                            searchViewModel.clearRecentSearches()
                        }
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "E94560"))
                    }
                    .padding(.horizontal, 20)
                    
                    ForEach(searchViewModel.recentSearches, id: \.self) { term in
                        Button {
                            searchViewModel.searchText = term
                            searchViewModel.performSearch()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.3))
                                Text(term)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Image(systemName: "arrow.up.left")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                    }
                }
            }
            
            // Popular Categories
            VStack(alignment: .leading, spacing: 12) {
                Text("Popular Categories")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 20)
                
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(PostCategory.allCases, id: \.self) { category in
                        Button {
                            searchViewModel.selectedCategory = category
                            searchViewModel.searchText = category.rawValue
                            searchViewModel.performSearch()
                        } label: {
                            VStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(hex: "E94560").opacity(0.1))
                                        .frame(height: 60)
                                    Image(systemName: category.icon)
                                        .font(.system(size: 22))
                                        .foregroundColor(Color(hex: "E94560"))
                                }
                                Text(category.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // MARK: - Results List
    private var resultsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(searchViewModel.results.count) results found")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 20)
                
                LazyVStack(spacing: 12) {
                    ForEach(searchViewModel.results) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostCardView(post: post)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Color(hex: "E94560"))
                .scaleEffect(1.2)
            Spacer()
        }
    }
    
    // MARK: - No Results
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.15))
            Text("No results for \"\(searchViewModel.searchText)\"")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            Text("Try different keywords or category")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    SearchView()
        .environmentObject(AuthViewModel())
}
