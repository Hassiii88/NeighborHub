import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            switch authViewModel.authState {
                
            case .splash:
                SplashView()
                
            case .loggedOut:
                LoginView()
                
            case .loggedIn:
                MainTabView()
            }
        }
        .animation(
            .easeInOut(duration: 0.35),
            value: authViewModel.authState
        )
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}
