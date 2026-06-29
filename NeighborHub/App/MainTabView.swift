import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - Tab 1: Home
            HomeFeedView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0
                          ? "house.fill" : "house")
                }
                .tag(0)
            
            // MARK: - Tab 2: Search
            SearchView()
                .tabItem {
                    Label("Search", systemImage: selectedTab == 1
                          ? "magnifyingglass.circle.fill" : "magnifyingglass")
                }
                .tag(1)
            
            // MARK: - Tab 3: Create Post
            CreatePostView()
                .tabItem {
                    Label("Post", systemImage: selectedTab == 2
                          ? "plus.app.fill" : "plus.app")
                }
                .tag(2)
            
            // MARK: - Tab 4: Chat
            ChatListView()
                .tabItem {
                    Label("Chat", systemImage: selectedTab == 3
                          ? "message.fill" : "message")
                }
                .tag(3)
            
            // MARK: - Tab 5: Profile
            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 4
                          ? "person.fill" : "person")
                }
                .tag(4)
        }
        .tint(Color(hex: "E94560"))
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    // MARK: - TabBar Appearance
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: "16213E"))
        
        appearance.stackedLayoutAppearance.normal.iconColor =
            UIColor.white.withAlphaComponent(0.3)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.3)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor =
            UIColor(Color(hex: "E94560"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "E94560"))
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
