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

    let modes = ["冷氣", "暖風", "除濕", "送風", "自動"]
    var body: some View {
        HStack(spacing: 8) { // 調整間距
            ForEach(modes, id: \.self) { mode in
                GeometryReader { geometry in
                    let buttonSize = geometry.size.width
                    Button(action: {
                        selectedMode = mode
                    }) {
                        Text(mode)
                            .font(.body)
                            .frame(width: buttonSize, height: buttonSize) // 使用容器的高度設置寬高
//                            .aspectRatio(1, contentMode: .fit) // 寬高比為 1:1，確保正方形
                            .background(selectedMode == mode ? .g_blue : Color(hex:"#F2F2F2"))
                            .foregroundColor(selectedMode == mode ? .white : Color(hex:"#7C7C7C"))
                    }
                    .buttonStyle(NoAnimationButtonStyle()) // 使用自訂樣式，完全禁用動畫
                    .cornerRadius(10)
                }
                .shadow(color: selectedMode == mode ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
            }
        }
        .aspectRatio(5, contentMode: .fit) // 根據按鈕數量讓高度自適應寬度
//        .frame(height: 80) // 設定父視圖的高度
    }
}

struct NoAnimationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label // 保持按鈕的標籤完全不變
    }
}
