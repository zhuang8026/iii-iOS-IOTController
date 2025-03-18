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
            ForEach(modes, id: \.self) { mode in
                Button(action: {
                    triggerHapticFeedback() // 震動控制
                    selectedMode = mode
                }) {
                    Text(verifyMode(mode))
                        .font(.body)
//                        .frame(height: 60.0) // 直接指定固定大小
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 按钮填充
                        .background(selectedMode == mode ? .g_blue : Color.light_gray)
                        .foregroundColor(selectedMode == mode ? .white : Color.heavy_gray)
                }
                .frame(maxWidth: .infinity) // 让每个按钮均分 HStack
                .aspectRatio(1, contentMode: .fit) // 保证按钮宽高相等
                .cornerRadius(UIScreen.main.bounds.width / CGFloat(modes.count) / 2) // 圆角 = 宽度一半
//                .buttonStyle(NoAnimationButtonStyle())
                .shadow(color: selectedMode == mode ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 0) // 适当增加两侧边距，防止贴边
        .frame(height: 70) // ✅ 确保整个 HStack 有固定高度
        .frame(maxWidth: .infinity) // 设置 HStack 的固定高度
    }
}


//struct NoAnimationButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label // 保持按鈕的標籤完全不變
//    }
//}
