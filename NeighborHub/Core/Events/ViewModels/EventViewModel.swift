//
//  EventViewModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
class EventViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var events: [EventModel] = []
    @Published var isLoading: Bool = false
    @Published var showCreateEvent: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false
    
    // Form fields
    @Published var eventTitle: String = ""
    @Published var eventDescription: String = ""
    @Published var eventDate: Date = Date().addingTimeInterval(86400)
    @Published var eventArea: String = "Rawalpindi"
    
    // MARK: - Private
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // MARK: - Fetch Events
    func fetchEvents() {
        isLoading = true
        listener?.remove()
        
        listener = db
            .collection(Constants.Collections.events)
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                        return
                    }
                    self.events = snapshot?.documents.compactMap {
                        try? $0.data(as: EventModel.self)
                    } ?? []
                }
            }
    }
    
    // MARK: - Create Event
    func createEvent(currentUser: UserModel) {
        guard !eventTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Event title is required"
            showError = true
            return
        }
        
        guard let userId = currentUser.id else { return }
        
        isLoading = true
        
        let event = EventModel(
            title: eventTitle.trimmingCharacters(in: .whitespaces),
            description: eventDescription,
            date: eventDate,
            area: eventArea,
            organizerId: userId,
            organizerName: currentUser.name
        )
        
        do {
            try db.collection(Constants.Collections.events)
                .addDocument(from: event) { [weak self] error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            self.showError = true
                        } else {
                            self.showSuccess = true
                            self.resetForm()
                            self.showCreateEvent = false
                        }
                    }
                }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    // MARK: - Join Event
    func joinEvent(eventId: String, userId: String) {
        db.collection(Constants.Collections.events)
            .document(eventId)
            .updateData([
                "attendees": FieldValue.arrayUnion([userId])
            ]) { _ in }
    }
    
    // MARK: - Leave Event
    func leaveEvent(eventId: String, userId: String) {
        db.collection(Constants.Collections.events)
            .document(eventId)
            .updateData([
                "attendees": FieldValue.arrayRemove([userId])
            ]) { _ in }
    }
    
    // MARK: - Reset Form
    func resetForm() {
        eventTitle = ""
        eventDescription = ""
        eventDate = Date().addingTimeInterval(86400)
        eventArea = "Rawalpindi"
    }
    
    // MARK: - Deinit
    deinit {
        listener?.remove()
    }
}
