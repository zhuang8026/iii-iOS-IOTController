//
//  ModeSelector.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/21.
//

import SwiftUI

/// 模式選擇視圖
struct ModeSelector: View {
    @Binding var selectedMode: Int  // 传入的模式索引
    var triggerAPI: () -> Void  // ✅ 傳入觸發 API 的方法

    let modes = ["冷氣", "暖風", "除濕", "自動", "送風"] // 修正索引对照关系
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(modes.indices, id: \.self) { index in
                Button(action: {
                    triggerHapticFeedback() // 震動控制
                    selectedMode = index // 存储索引
                }) {
                    Text(modes[index])
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 按钮填充
                        .background(selectedMode == index ? Color.g_green : Color.light_gray)
                        .foregroundColor(selectedMode == index ? Color.white : Color.gray)
                }
                .frame(maxWidth: .infinity) // 让每个按钮均分 HStack
                .aspectRatio(1, contentMode: .fit) // 保证按钮宽高相等
                .cornerRadius(UIScreen.main.bounds.width / CGFloat(modes.count) / 2) // 圆角 = 宽度一半
                .shadow(color: selectedMode == index ? Color.blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 0) // 适当增加两侧边距，防止贴边
        .frame(height: 70) // ✅ 确保整个 HStack 有固定高度
        .frame(maxWidth: .infinity) // 设置 HStack 的固定高度
        .onChange(of: selectedMode) { _ in  // ✅ 當 isPowerOn 變更時觸發 API
            triggerAPI()
        }
    }
}


//struct NoAnimationButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label // 保持按鈕的標籤完全不變
//    }
//}
