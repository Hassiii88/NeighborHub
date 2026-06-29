//
//  SettingsView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var notificationsEnabled: Bool = true
    @State private var emailNotifications: Bool = true
    @State private var darkMode: Bool = true
    @State private var showSignOutAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - User Info
                        userInfoSection
                            .padding(.top, 10)
                        
                        // MARK: - Notifications
                        settingsSection(title: "Notifications") {
                            SettingsToggleRow(
                                icon: "bell.fill",
                                title: "Push Notifications",
                                subtitle: "Get alerts for messages & emergencies",
                                color: Color(hex: "E94560"),
                                isOn: $notificationsEnabled
                            )
                            SettingsToggleRow(
                                icon: "envelope.fill",
                                title: "Email Notifications",
                                subtitle: "Receive updates via email",
                                color: Color.blue,
                                isOn: $emailNotifications
                            )
                        }
                        
                        // MARK: - Appearance
                        settingsSection(title: "Appearance") {
                            SettingsToggleRow(
                                icon: "moon.fill",
                                title: "Dark Mode",
                                subtitle: "Enable dark theme",
                                color: Color.purple,
                                isOn: $darkMode
                            )
                        }
                        
                        // MARK: - Account
                        settingsSection(title: "Account") {
                            SettingsLinkRow(
                                icon: "person.fill",
                                title: "Edit Profile",
                                color: Color.green
                            ) {
                                // Navigate to edit profile
                            }
                            SettingsLinkRow(
                                icon: "lock.fill",
                                title: "Change Password",
                                color: Color.orange
                            ) {
                                // Navigate to change password
                            }
                            SettingsLinkRow(
                                icon: "location.fill",
                                title: "Update Location",
                                color: Color.teal
                            ) {
                                // Navigate to location settings
                            }
                        }
                        
                        // MARK: - About
                        settingsSection(title: "About") {
                            SettingsLinkRow(
                                icon: "info.circle.fill",
                                title: "About NeighborHub",
                                color: Color.blue
                            ) {}
                            SettingsLinkRow(
                                icon: "doc.text.fill",
                                title: "Terms of Service",
                                color: Color.gray
                            ) {}
                            SettingsLinkRow(
                                icon: "hand.raised.fill",
                                title: "Privacy Policy",
                                color: Color.gray
                            ) {}
                            
                            HStack {
                                Spacer()
                                Text("Version 1.0.0")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.2))
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // MARK: - Danger Zone
                        settingsSection(title: "Account Actions") {
                            Button {
                                showSignOutAlert = true
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "E94560").opacity(0.15))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(hex: "E94560"))
                                    }
                                    Text("Sign Out")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(hex: "E94560"))
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            
                            Button {
                                showDeleteAlert = true
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red.opacity(0.15))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color.red)
                                    }
                                    Text("Delete Account")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color.red)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color(hex: "16213E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Sign Out?", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will be logged out of your account.")
            }
            .alert("Delete Account?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    // Delete account logic
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
        }
    }
    
    // MARK: - User Info Section
    private var userInfoSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.15))
                    .frame(width: 56, height: 56)
                Text(String(
                    (authViewModel.currentUser?.name ?? "U").prefix(1)
                ).uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "E94560"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authViewModel.currentUser?.name ?? "")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text(authViewModel.currentUser?.email ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(hex: "16213E"))
        .cornerRadius(16)
    }
    
    // MARK: - Settings Section Builder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.3))
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color(hex: "16213E"))
            .cornerRadius(16)
        }
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    var icon: String
    var title: String
    var subtitle: String
    var color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(hex: "E94560"))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(
            Divider()
                .background(Color.white.opacity(0.06)),
            alignment: .bottom
        )
    }
}

// MARK: - Settings Link Row
struct SettingsLinkRow: View {
    var icon: String
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .overlay(
                Divider()
                    .background(Color.white.opacity(0.06)),
                alignment: .bottom
            )
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}