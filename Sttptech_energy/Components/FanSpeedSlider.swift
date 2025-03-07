//
//  FanSpeedSlider.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/21.
//

import SwiftUI

/// 風速控制視圖
struct FanSpeedSlider: View {
    @Binding var fanSpeed: Double // 滑桿的當前值
    var triggerAPI: () -> Void  // ✅ 傳入觸發 API 的方法

    @State private var previousFanSpeed: Double = 2.0 // 記錄上一個值
    private let step: Double = 1.0
    


    var body: some View {
        VStack() {
            // 滑桿
            Slider(
                value: $fanSpeed,
                in: 1...4,
                step: step,
                onEditingChanged: { editing in
                    if !editing {
                        // 吸附到最近的整数值
                        withAnimation {
                            fanSpeed = (fanSpeed / step).rounded() * step
                        }
                    }
                }
//                minimumValueLabel: Text("1") // 左側數字
//                maximumValueLabel: Text("4")  // 右側數字
            )
//            { Text("") // 滑桿的描述標籤，可留空或加入額外的用途描述 }
                .accentColor(.g_blue)
                .onChange(of: fanSpeed) { oldValue, newValue in
                    print("風速: \(newValue)")

                    triggerAPI() // 觸發 POST API

                    guard newValue != previousFanSpeed else { return } // 防止重複觸發
                    triggerHapticFeedback(for: newValue)
                    previousFanSpeed = newValue
                    
                }
                .padding(.horizontal, 2)
            
            // 刻度線
            HStack() {
                ForEach(1..<5) { index in
                    ZStack() {
                        Rectangle()
                            .cornerRadius(10.0)
                            .frame(width: 2, height: 6) // 刻度線尺寸
                            .offset(x: 0, y: -15) // 向上微調刻度線
    //                        .frame(maxWidth: .infinity, alignment: .center) // 均勻分佈
                        Text("\(index)") // 顯示刻度數字
                            .font(.system(size: 18))
//                            .offset(x: 0, y: -10) // 向上微調刻度線
                    }
                    .padding(.bottom, -5)
                    if index != 4 {Spacer()}
                }
            }
            .padding(.horizontal, 8.5) // 左右邊距，確保刻度在滑桿範圍內

            // 刻度數字
//            HStack {
//                ForEach(1..<5) { index in
//                    Text("\(index)") // 顯示刻度數字
//                        .font(.system(size: 24, weight: .bold))
//                        .offset(x: 0, y: -20) // 向上微調刻度線
////                        .frame(maxWidth: .infinity, alignment: .center) // 均勻分佈
//                    if index != 4 {Spacer()}
//                }
//            }
//            .padding(.horizontal, 8) // 左右邊距，確保刻度在滑桿範圍內

         }
    }
    
    // 震動效果
    private func triggerHapticFeedback(for value: Double) {
//        guard value != previousFanSpeed else { return } // 防止重複觸發
        
        print("震動")
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}



