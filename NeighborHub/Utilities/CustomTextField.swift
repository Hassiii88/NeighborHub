//
//  CustomTextField.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import SwiftUI

// MARK: - Custom Text Field
struct CustomTextField: View {
    
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "E94560"))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .tint(Color(hex: "E94560"))
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.3))
                }
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

// MARK: - Custom Secure Field
struct CustomSecureField: View {
    
    var icon: String
    var placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "E94560"))
                .frame(width: 20)
            
            if isVisible {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .tint(Color(hex: "E94560"))
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .tint(Color(hex: "E94560"))
            }
            
            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.4))
                    .font(.system(size: 14))
            }
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

// MARK: - Area Picker Sheet
struct AreaPickerView: View {
    @Binding var selectedArea: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                List(Constants.pakistanAreas, id: \.self) { area in
                    Button {
                        selectedArea = area
                        dismiss()
                    } label: {
                        HStack {
                            Text(area)
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            if selectedArea == area {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "E94560"))
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Apna area chunao")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "E94560"))
                }
            }
        }
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}