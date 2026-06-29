//
//  RoundedCorner.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 23/06/2026.
//


import SwiftUI
import Foundation

// MARK: - Date Extension
extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Int(Date().timeIntervalSince(self))
        
        switch seconds {
        case 0..<60:
            return "Just now"
        case 60..<3600:
            return "\(seconds / 60)m ago"
        case 3600..<86400:
            return "\(seconds / 3600)h ago"
        case 86400..<604800:
            return "\(seconds / 86400)d ago"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            return formatter.string(from: self)
        }
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }
}

// MARK: - String Extension
extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        return self.count >= 6
    }
}

// MARK: - Double Extension
extension Double {
    func formattedPrice() -> String {
        if self == 0 { return "Free" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "Rs. \(formatted)"
    }
}

// MARK: - Color Extension
extension Color {
    static let appPrimary    = Color("AppPrimary")
    static let appSecondary  = Color("AppSecondary")
    static let appBackground = Color("AppBackground")
    static let appCard       = Color("AppCard")
    
    // Fallback hex init
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8) & 0xff) / 255
        let b = Double(int & 0xff) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - View Extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}