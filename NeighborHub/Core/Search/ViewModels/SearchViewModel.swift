//
//  SearchViewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var searchText: String = ""
    @Published var results: [PostModel] = []
    @Published var isLoading: Bool = false
    @Published var selectedCategory: PostCategory? = nil
    @Published var recentSearches: [String] = []
    
    // MARK: - Private
    private var searchTask: DispatchWorkItem?
    private let recentSearchesKey = "recentSearches"
    
    // MARK: - Init
    init() {
        loadRecentSearches()
    }
    
    // MARK: - Search with debounce
    func performSearch() {
        searchTask?.cancel()
        
        let text = searchText.trimmingCharacters(in: .whitespaces)
        
        guard !text.isEmpty else {
            results = []
            return
        }
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            self.searchPosts(query: text)
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: task)
    }
    
    // MARK: - Search Posts
    private func searchPosts(query: String) {
        PostService.shared.searchPosts(query: query) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(var posts):
                    // Category filter
                    if let category = self.selectedCategory {
                        posts = posts.filter { $0.category == category }
                    }
                    self.results = posts
                    self.saveRecentSearch(query)
                case .failure:
                    self.results = []
                }
            }
        }
    }
    
    // MARK: - Recent Searches
    private func saveRecentSearch(_ term: String) {
        var recent = recentSearches
        recent.removeAll { $0 == term }
        recent.insert(term, at: 0)
        recentSearches = Array(recent.prefix(5))
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(
            forKey: recentSearchesKey
        ) ?? []
    }
}