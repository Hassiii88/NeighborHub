//
//  LoginView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var navigateToRegister: Bool = false
    @State private var animateForm: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // MARK: - Header
                        headerSection
                        
                        // MARK: - Form
                        formSection
                            .padding(.top, 40)
                        
                        // MARK: - Login Button
                        loginButton
                            .padding(.top, 30)
                        
                        // MARK: - Divider
                        dividerSection
                            .padding(.vertical, 24)
                        
                        // MARK: - Register Link
                        registerLink
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView()
            }
            .alert("Error", isPresented: $authViewModel.showError) {
                Button("OK") { authViewModel.showError = false }
            } message: {
                Text(authViewModel.errorMessage)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateForm = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Logo
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "house.and.flag.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .foregroundColor(Color(hex: "E94560"))
            }
            .padding(.top, 60)
            
            Text("Welcome Back!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Sign in to your account")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.5))
        }
        .opacity(animateForm ? 1 : 0)
        .offset(y: animateForm ? 0 : -20)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 16) {
            
            // Email Field
            CustomTextField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                keyboardType: .emailAddress
            )
            
            // Password Field
            CustomSecureField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                isVisible: $isPasswordVisible
            )
        }
        .opacity(animateForm ? 1 : 0)
        .offset(y: animateForm ? 0 : 20)
    }
    
    // MARK: - Login Button
    private var loginButton: some View {
        Button {
            hideKeyboard()
            authViewModel.login(email: email, password: password)
        } label: {
            ZStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Login")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                authViewModel.isLoading
                ? Color(hex: "E94560").opacity(0.6)
                : Color(hex: "E94560")
            )
            .cornerRadius(14)
        }
        .disabled(authViewModel.isLoading)
        .opacity(animateForm ? 1 : 0)
    }
    
    // MARK: - Divider
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
            
            Text("OR")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 12)
            
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
        }
    }
    
    // MARK: - Register Link
    private var registerLink: some View {
        HStack(spacing: 4) {
            Text("New user?")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 15))
            
            Button("Create account") {
                navigateToRegister = true
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color(hex: "E94560"))
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
