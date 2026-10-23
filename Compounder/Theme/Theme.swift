import SwiftUI

enum Theme {
    static let background = Color(hex: 0x232334)
    static let card = Color(hex: 0x2E2E44)
    static let raised = Color(hex: 0x3A3A54)
    static let track = Color(hex: 0x1C1C2A)
    static let tabBar = Color(hex: 0x2C2C41)
    static let iconButton = Color(hex: 0x30304A)
    static let divider = Color(hex: 0x393952)
    static let outline = Color(hex: 0x4A4A64)

    static let text = Color(hex: 0xF4F4FA)
    static let textSoft = Color(hex: 0xD9D9EA)
    static let secondary = Color(hex: 0xA5A5BF)
    static let icon = Color(hex: 0xC9C9DE)

    static let accent = Color(hex: 0xFF8A3D)
    static let purple = Color(hex: 0xA78BFA)
    static let green = Color(hex: 0x4ADE80)
    static let onAccent = Color(hex: 0x1C1C2A)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Gradient styles for the plan card.
enum CardTheme: String, CaseIterable, Codable {
    case sunset, ocean, aurora

    var colors: [Color] {
        switch self {
        case .sunset: return [Color(hex: 0x46367A), Color(hex: 0xA3306F), Color(hex: 0xEF4638), Color(hex: 0xFF9A3C)]
        case .ocean: return [Color(hex: 0x26346A), Color(hex: 0x2459A6), Color(hex: 0x138FB0), Color(hex: 0x2FC6B5)]
        case .aurora: return [Color(hex: 0x2D2660), Color(hex: 0x5B3FB8), Color(hex: 0xA646C8), Color(hex: 0xE2539E)]
        }
    }

    /// Soft light in the card's top corner.
    var sheen: Color {
        switch self {
        case .sunset: return Color(hex: 0x7A62D6, opacity: 0.85)
        case .ocean: return Color(hex: 0x6078E6, opacity: 0.8)
        case .aurora: return Color(hex: 0x50C8DC, opacity: 0.55)
        }
    }

    /// The two shapes peeking out from behind the card.
    var blobs: (top: [Color], bottom: [Color]) {
        switch self {
        case .sunset: return ([Color(hex: 0xFF3FA4), Color(hex: 0xC2187A)], [Color(hex: 0xFFB341), Color(hex: 0xFF6A2B)])
        case .ocean: return ([Color(hex: 0x38D9E8), Color(hex: 0x1A7FC4)], [Color(hex: 0x7AE8B8), Color(hex: 0x20B39A)])
        case .aurora: return ([Color(hex: 0xF472B6), Color(hex: 0x9D3FD0)], [Color(hex: 0x38D9E8), Color(hex: 0x6D5DF5)])
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
