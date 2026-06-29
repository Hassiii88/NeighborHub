import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var maxSelection: Int = 4
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)
            if let image = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    if self.parent.selectedImages.count < self.parent.maxSelection {
                        self.parent.selectedImages.append(image)
                    }
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Image Source Picker
struct ImageSourcePicker: View {
    @Binding var selectedImages: [UIImage]
    var maxSelection: Int = 4
    @Binding var isPresented: Bool
    
    @State private var showCamera: Bool = false
    @State private var showGallery: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Title
                    Text("Select Image Source")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.vertical, 16)
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Camera Button
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            isPresented = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showCamera = true
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "E94560"))
                                    .frame(width: 30)
                                Text("Take Photo")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                    
                    // Gallery Button
                    Button {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showGallery = true
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "E94560"))
                                .frame(width: 30)
                            Text("Choose from Gallery")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Cancel
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "E94560"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(Color(hex: "16213E"))
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(
                selectedImages: $selectedImages,
                maxSelection: maxSelection,
                sourceType: .camera
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showGallery) {
            ImagePicker(
                selectedImages: $selectedImages,
                maxSelection: maxSelection,
                sourceType: .photoLibrary
            )
            .ignoresSafeArea()
        }
    }
}
