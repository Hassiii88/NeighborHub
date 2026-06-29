//
//  EventModel.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation
import FirebaseFirestore

struct EventModel: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var date: Date
    var area: String
    var organizerId: String
    var organizerName: String
    var attendees: [String]    // userIds list
    var imageURL: String
    var createdAt: Date
    
    var attendeeCount: Int {
        attendees.count
    }
    
    init(
        title: String,
        description: String,
        date: Date,
        area: String,
        organizerId: String,
        organizerName: String
    ) {
        self.title = title
        self.description = description
        self.date = date
        self.area = area
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.attendees = []
        self.imageURL = ""
        self.createdAt = Date()
    }
}