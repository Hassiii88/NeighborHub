//
//  Constants.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import Foundation

struct Constants {
    
    // MARK: - Cloudinary Config
    struct Cloudinary {
        static let cloudName    = "dumfc0rv4"
        static let uploadPreset = "neighborrhub_preset"
        static let baseURL = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
    }
    
    // MARK: - Firestore Collections
    struct Collections {
        static let users         = "users"
        static let posts         = "posts"
        static let chats         = "chats"
        static let messages      = "messages"
        static let reviews       = "reviews"
        static let events        = "events"
        static let notifications = "notifications"
    }
    
    // MARK: - Pakistan Cities / Areas
    static let pakistanAreas = [
        "Rawalpindi", "Islamabad", "Lahore", "Karachi",
        "Peshawar", "Quetta", "Multan", "Faisalabad",
        "Sialkot", "Gujranwala", "Hyderabad", "Abbottabad","Azad Kashmir"
    ]
    
    // MARK: - App Config
    struct App {
        static let maxImagesPerPost   = 4
        static let maxImageSizeMB     = 2.0
        static let defaultRadius      = 10.0   // km
    }
}
