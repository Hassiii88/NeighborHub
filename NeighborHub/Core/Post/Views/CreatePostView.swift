import SwiftUI

struct CreatePostView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CreatePostViewModel()
    
    @State private var showImagePicker: Bool = false
    @State private var showAreaPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        categorySection
                        titleSection
                        descriptionSection
                        priceSection
                        areaSection
                        imagesSection
                        submitButton
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    selectedImages: $viewModel.selectedImages,
                    maxSelection: Constants.App.maxImagesPerPost
                )
            }
            .sheet(isPresented: $showAreaPicker) {
                AreaPickerView(selectedArea: $viewModel.selectedArea)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.showError = false }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Post Published! 🎉", isPresented: $viewModel.isSuccess) {
                Button("OK") {}
            } message: {
                Text("Your post has been successfully published.")
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Create New Post")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Share what you need with your community")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(.top, 10)
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Select Category")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(PostCategory.allCases, id: \.self) { category in
                        Button {
                            viewModel.selectedCategory = category
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 18))
                                Text(category.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(
                                viewModel.selectedCategory == category
                                ? .white : .white.opacity(0.4)
                            )
                            .frame(width: 75, height: 65)
                            .background(
                                viewModel.selectedCategory == category
                                ? Color(hex: "E94560")
                                : Color.white.opacity(0.07)
                            )
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Title *")
            TextField("", text: $viewModel.title)
                .placeholder(when: viewModel.title.isEmpty) {
                    Text("e.g. Honda City 2020 for sale")
                        .foregroundColor(.white.opacity(0.3))
                }
                .foregroundColor(.white)
                .tint(Color(hex: "E94560"))
                .padding(16)
                .background(Color.white.opacity(0.07))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            HStack {
                Spacer()
                Text("\(viewModel.title.count)/80")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Description *")
            ZStack(alignment: .topLeading) {
                if viewModel.postdescription.isEmpty {
                    Text("Provide details like condition, age, features...")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 16))
                        .padding(16)
                }
                TextEditor(text: $viewModel.postdescription)
                    .foregroundColor(.white)
                    .tint(Color(hex: "E94560"))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .padding(12)
            }
            .background(Color.white.opacity(0.07))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Price Section
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Price (Optional - 0 for Free)")
            HStack(spacing: 12) {
                Text("Rs.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "E94560"))
                TextField("", text: $viewModel.price)
                    .placeholder(when: viewModel.price.isEmpty) {
                        Text("0").foregroundColor(.white.opacity(0.3))
                    }
                    .foregroundColor(.white)
                    .tint(Color(hex: "E94560"))
                    .keyboardType(.numberPad)
            }
            .padding(16)
            .background(Color.white.opacity(0.07))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Area Section
    private var areaSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Location")
            Button {
                showAreaPicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color(hex: "E94560"))
                    Text(viewModel.selectedArea)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 13))
                }
                .padding(16)
                .background(Color.white.opacity(0.07))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Images Section
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Images (Optional - Max 4)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if viewModel.selectedImages.count < Constants.App.maxImagesPerPost {
                        Button {
                            showImagePicker = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "E94560"))
                                Text("Add Image")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .frame(width: 90, height: 90)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(hex: "E94560").opacity(0.3),
                                        style: StrokeStyle(lineWidth: 1.5, dash: [5])
                                    )
                            )
                        }
                    }
                    
                    ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: viewModel.selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .cornerRadius(12)
                                .clipped()
                            Button {
                                viewModel.removeImage(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .background(Color(hex: "E94560"))
                                    .clipShape(Circle())
                            }
                            .offset(x: 6, y: -6)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            hideKeyboard()
            if let user = authViewModel.currentUser {
                viewModel.createPost(currentUser: user)
            }
        } label: {
            ZStack {
                if viewModel.isLoading {
                    VStack(spacing: 6) {
                        ProgressView().tint(.white)
                        if viewModel.uploadProgress > 0 {
                            Text("Uploading... \(viewModel.uploadProgress)%")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                } else {
                    Label("Publish Post", systemImage: "paperplane.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                viewModel.isFormValid
                ? Color(hex: "E94560")
                : Color(hex: "E94560").opacity(0.4)
            )
            .cornerRadius(14)
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }
    
    // MARK: - Helper
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white.opacity(0.5))
    }
}

#Preview {
    CreatePostView()
        .environmentObject(AuthViewModel())
}
