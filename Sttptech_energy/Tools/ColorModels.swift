//
//  Models.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/17.
//

import SwiftUI

// MARK: - 自定義 Color 擴展以支援 Hex 顏色
extension Color {
    static let g_blue = Color(hex: "#3D668F")       // 主要 文字深藍色
    static let g_green = Color(hex: "#1FA2A0")      // 主要綠色
    static let light_green = Color(hex: "#DEEBEA")  // 主要背景淡綠色
    static let light_gray = Color(hex: "#F2F2F2")   // 淺灰色
    static let heavy_gray = Color(hex: "#7C7C7C")   // 深灰色  次等 文字顏色
    static let light_blue = Color(hex: "#EEF1FB")   // 深灰藍色
    static let warning = Color(hex: "#FC6559")      // 危險紅色

    static let fan_purple = Color(hex: "#B7A8DE")
    static let fan_blue = Color(hex: "#8DA8E3")
    static let fan_cyan = Color(hex: "#A7E1E8")
    static let fan_teal = Color(hex: "#5FC6BE")
    static let fan_yellow = Color(hex: "#E0CE6D")
    static let fan_orange = Color(hex: "#E0A26D")
    
    
    
    init(hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        assert(hex.count == 3 || hex.count == 6 || hex.count == 8, "Invalid hex code used. hex count is #(3, 6, 8).")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(alpha)
        )
    }
}


// MARK: - 自定義 進度條上下左右
enum CornerType {
    case topLeft, topRight, bottomLeft, bottomRight
}
