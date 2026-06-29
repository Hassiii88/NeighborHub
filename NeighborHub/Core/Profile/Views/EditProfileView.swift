import SwiftUI

struct EditProfileView: View {
    
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedArea: String = ""
    @State private var showImagePicker: Bool = false
    @State private var showAreaPicker: Bool = false
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Profile Image
                        imageSection
                            .padding(.top, 20)
                        
                        // MARK: - Form
                        formSection
                        
                        // MARK: - Save Button
                        saveButton
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .toolbarBackground(Color(hex: "16213E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    selectedImages: Binding(
                        get: {
                            if let img = userViewModel.selectedImage {
                                return [img]
                            }
                            return []
                        },
                        set: { images in
                            userViewModel.selectedImage = images.first
                        }
                    ),
                    maxSelection: 1
                )
            }
            .sheet(isPresented: $showAreaPicker) {
                AreaPickerView(selectedArea: $selectedArea)
            }
            .alert("Success!", isPresented: $userViewModel.showSuccess) {
                Button("OK") {
                    userViewModel.showSuccess = false
                    // Update authViewModel current user
                    if let userId = authViewModel.currentUser?.id {
                        authViewModel.refreshCurrentUser(uid: userId)
                    }
                    dismiss()
                }
            } message: {
                Text(userViewModel.successMessage)
            }
            .alert("Error", isPresented: $userViewModel.showError) {
                Button("OK") { userViewModel.showError = false }
            } message: {
                Text(userViewModel.errorMessage)
            }
            .onAppear {
                name = userViewModel.user?.name ?? ""
                selectedArea = userViewModel.user?.area ?? ""
            }
        }
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                // Profile Image
                ZStack {
                    Circle()
                        .fill(Color(hex: "16213E"))
                        .frame(width: 110, height: 110)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "E94560"), lineWidth: 3)
                        )
                    
                    if let selected = userViewModel.selectedImage {
                        Image(uiImage: selected)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                    } else if let url = userViewModel.user?.profileImageURL,
                              !url.isEmpty {
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView().tint(Color(hex: "E94560"))
                        }
                        .frame(width: 104, height: 104)
                        .clipShape(Circle())
                    } else {
                        Text(String(
                            (userViewModel.user?.name ?? "U").prefix(1)
                        ).uppercased())
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(hex: "E94560"))
                    }
                }
                
                // Camera Button
                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "E94560"))
                            .frame(width: 36, height: 36)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "1A1A2E"), lineWidth: 3)
                    )
                }
                .offset(x: 4, y: 4)
            }
            
            if userViewModel.selectedImage != nil {
                Text("New photo selected — save to upload")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "E94560"))
            }
            
            if userViewModel.isUploadingImage {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(Color(hex: "E94560"))
                        .scaleEffect(0.8)
                    Text("Uploading photo...")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 16) {
            
            // Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(hex: "E94560"))
                        .frame(width: 20)
                    TextField("", text: $name)
                        .placeholder(when: name.isEmpty) {
                            Text("Your full name")
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .foregroundColor(.white)
                        .tint(Color(hex: "E94560"))
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
            
            // Area
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Area")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                Button {
                    showAreaPicker = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color(hex: "E94560"))
                            .frame(width: 20)
                        Text(selectedArea.isEmpty ? "Select area" : selectedArea)
                            .foregroundColor(
                                selectedArea.isEmpty
                                ? .white.opacity(0.3)
                                : .white
                            )
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
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                userViewModel.errorMessage = "Name cannot be empty"
                userViewModel.showError = true
                return
            }
            if let userId = userViewModel.user?.id {
                userViewModel.updateProfile(
                    userId: userId,
                    name: name,
                    area: selectedArea
                )
            }
        } label: {
            ZStack {
                if userViewModel.isUpdating {
                    HStack(spacing: 10) {
                        ProgressView().tint(.white)
                        Text(userViewModel.isUploadingImage
                             ? "Uploading photo..."
                             : "Saving changes...")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    }
                } else {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color(hex: "E94560"))
            .cornerRadius(14)
        }
        .disabled(userViewModel.isUpdating)
    }
}

#Preview {
    EditProfileView(userViewModel: UserViewModel())
        .environmentObject(AuthViewModel())
}
