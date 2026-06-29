//
//  EmergencyView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import SwiftUI
import FirebaseFirestore

struct EmergencyView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = EmergencyViewModel()
    @State private var showCreateAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - SOS Button
                    sosSection
                        .padding(.top, 20)
                    
                    // MARK: - Emergency Types
                    emergencyTypesSection
                        .padding(.top, 24)
                    
                    // MARK: - Recent Alerts
                    recentAlertsSection
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .alert("Send Emergency Alert?", isPresented: $showCreateAlert) {
                Button("Send Alert", role: .destructive) {
                    viewModel.sendEmergencyAlert(
                        user: authViewModel.currentUser
                    )
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will notify your entire neighborhood immediately.")
            }
            .alert("Alert Sent!", isPresented: $viewModel.showSuccess) {
                Button("OK") {}
            } message: {
                Text("Your emergency alert has been sent to the community.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.showError = false }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                viewModel.fetchEmergencyPosts()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Emergency")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Community safety network")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            
            // Active alerts badge
            if !viewModel.emergencyPosts.isEmpty {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "E94560"))
                        .frame(width: 8, height: 8)
                    Text("\(viewModel.emergencyPosts.count) active")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "E94560"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "E94560").opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - SOS Section
    private var sosSection: some View {
        VStack(spacing: 16) {
            
            // SOS Button
            Button {
                showCreateAlert = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "E94560").opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Color(hex: "E94560").opacity(0.25))
                        .frame(width: 110, height: 110)
                    
                    Circle()
                        .fill(Color(hex: "E94560"))
                        .frame(width: 86, height: 86)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                        Text("SOS")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(viewModel.isSending)
            
            Text("Press to alert your community")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.4))
        }
    }
    
    // MARK: - Emergency Types
    private var emergencyTypesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emergency Type")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EmergencyType.allCases, id: \.self) { type in
                        EmergencyTypeChip(
                            type: type,
                            isSelected: viewModel.selectedType == type
                        ) {
                            viewModel.selectedType = type
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Recent Alerts
    private var recentAlertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Alerts")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 20)
            
            if viewModel.emergencyPosts.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color.green.opacity(0.5))
                        Text("All clear! No active alerts.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.emergencyPosts) { post in
                            EmergencyAlertRow(post: post)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Emergency Type Chip
struct EmergencyTypeChip: View {
    var type: EmergencyType
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(
                        isSelected ? .white : Color(hex: "E94560")
                    )
                Text(type.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(
                        isSelected ? .white : .white.opacity(0.6)
                    )
            }
            .frame(width: 80, height: 72)
            .background(
                isSelected
                ? Color(hex: "E94560")
                : Color(hex: "E94560").opacity(0.1)
            )
            .cornerRadius(14)
        }
    }
}

// MARK: - Emergency Alert Row
struct EmergencyAlertRow: View {
    var post: PostModel
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "E94560"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(post.area)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                    Text("•")
                        .foregroundColor(.white.opacity(0.2))
                    Text(post.createdAt.timeAgoDisplay())
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            Spacer()
            
            Text("Active")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "E94560"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "E94560").opacity(0.12))
                .cornerRadius(6)
        }
        .padding(14)
        .background(Color(hex: "16213E"))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(hex: "E94560").opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Emergency Type Enum
enum EmergencyType: String, CaseIterable {
    case fire = "Fire"
    case medical = "Medical"
    case theft = "Theft"
    case accident = "Accident"
    case flood = "Flood"
    
    var icon: String {
        switch self {
        case .fire:     return "flame.fill"
        case .medical:  return "cross.fill"
        case .theft:    return "lock.open.fill"
        case .accident: return "car.fill"
        case .flood:    return "drop.fill"
        }
    }
    
    var title: String { rawValue }
}

#Preview {
    EmergencyView()
        .environmentObject(AuthViewModel())
}