//
//  SplashView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//

import SwiftUI

struct SplashView: View {
    
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "1A1A2E")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Spacer()
                
                // Logo Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "E94560").opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color(hex: "E94560").opacity(0.25))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "house.and.flag.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color(hex: "E94560"))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App Name
                VStack(spacing: 8) {
                    Text("NeighborHub")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                    
                    Text("Connect with your community")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "E94560"))
                        .opacity(taglineOpacity)
                }
                
                Spacer()
                
                // Bottom tagline
                Text("Made with ❤️ for Pakistan")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 40)
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            animateSplash()
        }
    }
    
    // MARK: - Animation
    private func animateSplash() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.5).delay(0.4)) {
            textOpacity = 1.0
        }
        
        withAnimation(.easeIn(duration: 0.5).delay(0.7)) {
            taglineOpacity = 1.0
        }
    }
}

#Preview {
    SplashView()
}
