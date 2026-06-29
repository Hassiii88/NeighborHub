//
//  RegisterView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedArea: String = "Rawalpindi"
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var showAreaPicker: Bool = false
    @State private var animateForm: Bool = false
    
    var body: some View {
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
                        .padding(.top, 36)
                    
                    // MARK: - Register Button
                    registerButton
                        .padding(.top, 30)
                    
                    // MARK: - Login Link
                    loginLink
                        .padding(.top, 24)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showAreaPicker) {
            AreaPickerView(selectedArea: $selectedArea)
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
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Create Account")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            Text("Join your community")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.5))
        }
        .opacity(animateForm ? 1 : 0)
    }
    
    // MARK: - Form
    private var formSection: some View {
        VStack(spacing: 14) {
            
            // Name
            CustomTextField(
                icon: "person.fill",
                placeholder: "Full name",
                text: $name
            )
            
            // Email
            CustomTextField(
                icon: "envelope.fill",
                placeholder: "Email address",
                text: $email,
                keyboardType: .emailAddress
            )
            
            // Password
            CustomSecureField(
                icon: "lock.fill",
                placeholder: "Password (minimum 6 characters)",
                text: $password,
                isVisible: $isPasswordVisible
            )
            
            // Confirm Password
            CustomSecureField(
                icon: "lock.shield.fill",
                placeholder: "Confirm password",
                text: $confirmPassword,
                isVisible: $isConfirmPasswordVisible
            )
            
            // Area Picker
            Button {
                showAreaPicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color(hex: "E94560"))
                        .frame(width: 20)
                    
                    Text(selectedArea)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 13))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 17)
                .background(Color.white.opacity(0.07))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .opacity(animateForm ? 1 : 0)
        .offset(y: animateForm ? 0 : 20)
    }
    
    // MARK: - Register Button
    private var registerButton: some View {
        Button {
            hideKeyboard()
            guard password == confirmPassword else {
                authViewModel.errorMessage = "Passwords do not match"
                authViewModel.showError = true
                return
            }
            authViewModel.register(
                name: name,
                email: email,
                password: password,
                area: selectedArea
            )
        } label: {
            ZStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(hex: "E94560"))
            .cornerRadius(14)
        }
        .disabled(authViewModel.isLoading)
        .opacity(animateForm ? 1 : 0)
    }
    
    // MARK: - Login Link
    private var loginLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 15))
            
            Button("Login") {
                dismiss()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(Color(hex: "E94560"))
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
