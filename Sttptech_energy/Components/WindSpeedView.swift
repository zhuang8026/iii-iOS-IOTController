//
//  FanSpeedSlider.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/21.
//

import SwiftUI
struct WindSpeedView: View {
    // 風速選項
//    let windSpeeds = ["自動", "低", "中", "高", "強", "最強"]
    let windSpeeds = ["auto", "low", "medium", "high", "strong", "max"]

    let colors: [Color] = [Color.fan_purple, Color.fan_blue, Color.fan_cyan, Color.fan_teal, Color.fan_yellow, Color.fan_orange]
    
//    @State private var selectedSpeed: String = "低" // 預設選擇 "低"
    @Binding var selectedSpeed: String // 🔥 使用 @Binding 讓 `selectedSpeed` 可與外部變數同步

    /// **模式轉換函式**
    private func verifyMode(_ mode: String) -> String {
        switch mode {
        case "auto": return "自動"
        case "low": return "低"
        case "medium": return "中"
        case "high": return "高"
        case "strong": return "強"
        case "max": return "最強"
        default: return "無法辨識模式"
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // 風速選項
            HStack(spacing: 4) {
                ForEach(Array(windSpeeds.enumerated()), id: \.element) { index, speed in
                    ZStack {
                        // 風速按鈕
                        Text(verifyMode(speed))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
//                            .frame(width: 60, height: 80)
                            .frame(maxWidth: 60, maxHeight: 80)
                            .background(colors[index])
                            .cornerRadius(10)
                            .shadow(color: selectedSpeed == speed ? .gray.opacity(0.6) : .clear, radius: 5, x: 0, y: 0)
                            .onTapGesture {
                                withAnimation {
                                    selectedSpeed = speed
                                    triggerHapticFeedback() // 觸發震動
                                }
                            }
                        
                        // 葉子圖示 (僅在選中時顯示)
                        if selectedSpeed == speed {
                            Image("leaves") // 確保 "leaves.png" 已加入 Assets
                                .resizable()
                                .frame(width: 40 , height: 40)
                                .offset(x: 05, y: -40) // 調整葉子位置
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 2, y: 2) // ✅ 添加陰影
                        }
                    }
                }
            }
//            .padding(.top, 5)
        }
//        .padding()
//        .background(Color(red: 0.9, green: 0.95, blue: 0.94)) // 背景色
    }
}




