//
//  ModeSelector.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/21.
//

import SwiftUI

/// 模式選擇視圖
struct ModeSelector: View {
    @Binding var selectedMode: String
    @Binding var modes: [String]
    
    /// 全部支援的模式（你也可以從外部傳入，這裡 hardcoded 範例）
    private let allFanLevels = ["cool", "dry", "fan", "auto", "heat"]

    /// **模式轉換函式**
    private func verifyMode(_ mode: String) -> String {
        switch mode {
        case "cool": return "冷氣"
        case "heat": return "暖風"
        case "dry": return "除濕"
        case "fan": return "送風"
        case "auto": return "自動"
        default: return "其他"
        }
    }

    var body: some View {
           HStack(spacing: 8) {
               ForEach(allFanLevels, id: \.self) { mode in
                   let isAvailable = modes.contains(mode)
                   Button(action: {
                       if isAvailable {
                           triggerHapticFeedback()
                           selectedMode = mode
                       }
                   }) {
                       Text(verifyMode(mode))
                           .font(.body)
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                           .background(
                               selectedMode == mode && isAvailable ? .g_blue :
                               isAvailable ? Color.light_gray : Color.gray.opacity(0.2)
                           )
                           .foregroundColor(
                               selectedMode == mode && isAvailable ? .white :
                               isAvailable ? .heavy_gray : .gray
                           )
                   }
                   .frame(maxWidth: .infinity)
                   .aspectRatio(1, contentMode: .fit)
                   .cornerRadius(UIScreen.main.bounds.width / CGFloat(allFanLevels.count) / 2)
                   .shadow(color: selectedMode == mode && isAvailable ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
               }
           }
           .padding(.horizontal, 0)
           .frame(height: 70)
           .frame(maxWidth: .infinity)
       }
}


//struct NoAnimationButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label // 保持按鈕的標籤完全不變
//    }
//}
