//
//  MapViewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import Foundation
import MapKit
import CoreLocation
import FirebaseFirestore
import Combine
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    // MARK: - Published
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 33.6007,
            longitude: 73.0679
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.05,
            longitudeDelta: 0.05
        )
    )
    @Published var posts: [PostModel] = []
    @Published var selectedPost: PostModel? = nil
    @Published var isLoading: Bool = false
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var locationPermissionDenied: Bool = false
    @Published var selectedCategory: PostCategory? = nil
    
    // MARK: - Private
    private var locationManager = CLLocationManager()
    private var listener: ListenerRegistration?
    
    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Location Delegate
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.locationPermissionDenied = true
            }
        default:
            break
        }
    }
    
    // MARK: - Fetch Map Posts
    func fetchMapPosts(category: PostCategory? = nil) {
        isLoading = true
        listener?.remove()
        
        listener = PostService.shared.fetchPosts(
            area: nil,
            category: category
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success(let posts) = result {
                    // Only posts with valid coordinates
                    self.posts = posts.filter {
                        $0.latitude != 0.0 && $0.longitude != 0.0
                    }
                }
            }
        }
    }
    
    // MARK: - Filter by Category
    func filterByCategory(_ category: PostCategory?) {
        selectedCategory = category
        fetchMapPosts(category: category)
    }
    
    // MARK: - Deinit
    deinit {
        listener?.remove()
    }
}
