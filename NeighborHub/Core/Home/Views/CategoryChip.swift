import SwiftUI

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(
                        isSelected ? Color.white : Color.white.opacity(0.85)
                    )
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        isSelected ? Color.white : Color.white.opacity(0.85)
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? Color(hex: "E94560")
                        : Color.white.opacity(0.08)
                    )
            )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
        .accessibilityLabel(
            Text(isSelected ? "\(title), selected" : "\(title), not selected")
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
#Preview("CategoryChip Examples") {
    VStack(spacing: 12) {
        
        CategoryChip(
            title: "All",
            icon: "square.grid.2x2.fill",
            isSelected: true
        ) {}
        
        CategoryChip(
            title: "Help",
            icon: "hands.sparkles.fill",
            isSelected: false
        ) {}
        
        CategoryChip(
            title: "Events",
            icon: "calendar",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.black)
}
