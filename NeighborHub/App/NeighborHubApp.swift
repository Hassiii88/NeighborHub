//
//  NeighborHubApp.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//

import SwiftUI
import Firebase

@main
struct NeighborHubApp: App {
    
    // AppDelegate connect karo
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Auth state poore app mein available hoga
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
