import SwiftUI

extension Color {
    init(hex: String) {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

/// Colors lifted from the "Industry" design system tokens the mockups were built on.
enum RG {
    static let background = Color(hex: "F5F5F8")
    static let surface = Color.white
    static let ink = Color(hex: "1D1F20")
    static let textSecondary = Color(hex: "7A7A7D")
    static let textTertiary = Color(hex: "98989B")
    static let divider = Color(hex: "1D1F20").opacity(0.07)

    static let accent = Color(hex: "5980A6")
    static let accentDeep = Color(hex: "416180")
    static let accentTint = Color(hex: "5980A6").opacity(0.1)

    static let safe = Color(hex: "4A7F5E")
    static let safeTint = Color(hex: "4A7F5E").opacity(0.12)
    static let approach = Color(hex: "A1762F")
    static let approachTint = Color(hex: "A1762F").opacity(0.12)
    static let urgent = Color(hex: "B8503A")
    static let urgentTint = Color(hex: "B8503A").opacity(0.1)
}

extension Font {
    /// Stands in for the brand's Barlow Condensed until real font files are added to the project.
    static func rgHeading(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    /// Stands in for the brand's Barlow.
    static func rgBody(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

extension View {
    func rgCard(padding: CGFloat = 16, radius: CGFloat = 20) -> some View {
        self.padding(padding)
            .background(RG.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
    }
}
