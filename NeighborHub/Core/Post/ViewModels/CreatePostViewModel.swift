import Foundation
import UIKit
import FirebaseAuth
import CoreLocation
import Combine

class CreatePostViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published
    @Published var title: String = ""
    @Published var postdescription: String = ""
    @Published var selectedCategory: PostCategory = .sell
    @Published var price: String = ""
    @Published var selectedArea: String = "Rawalpindi"
    @Published var selectedImages: [UIImage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isSuccess: Bool = false
    @Published var uploadProgress: Int = 0
    @Published var currentLatitude: Double = 0.0
    @Published var currentLongitude: Double = 0.0
    
    // MARK: - Private
    private var locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !postdescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        title.count >= 5
    }
    
    // MARK: - Init
    override init() {
        super.init()
        setupLocation()
    }
    
    // MARK: - Location Setup
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Location Delegate
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.currentLatitude = location.coordinate.latitude
                self.currentLongitude = location.coordinate.longitude
            }
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Create Post
    func createPost(currentUser: UserModel) {
        guard isFormValid else {
            showErrorMessage("Title and description are required (title min 5 characters)")
            return
        }
        
        isLoading = true
        uploadProgress = 0
        
        let priceValue = Double(price) ?? 0.0
        
        var newPost = PostModel(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            price: priceValue,
            userId: currentUser.id ?? "",
            userName: currentUser.name,
            area: selectedArea,
            latitude: currentLatitude,
            longitude: currentLongitude
        )
        
        if !selectedImages.isEmpty {
            StorageService.shared.uploadMultipleImages(
                selectedImages,
                folder: "neighborrhub/posts",
                progressHandler: { [weak self] uploaded, total in
                    DispatchQueue.main.async {
                        self?.uploadProgress = Int(
                            (Double(uploaded) / Double(total)) * 100
                        )
                    }
                }
            ) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let urls):
                    newPost.imageURLs = urls
                    self.savePostToFirestore(newPost)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.showErrorMessage(error.localizedDescription)
                    }
                }
            }
        } else {
            savePostToFirestore(newPost)
        }
    }
    
    // MARK: - Save to Firestore
    private func savePostToFirestore(_ post: PostModel) {
        PostService.shared.createPost(post) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.isSuccess = true
                    self.resetForm()
                case .failure(let error):
                    self.showErrorMessage(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Reset Form
    func resetForm() {
        title = ""
        postdescription = ""
        selectedCategory = .sell
        price = ""
        selectedImages = []
        uploadProgress = 0
    }
    
    // MARK: - Remove Image
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    // MARK: - Error
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
