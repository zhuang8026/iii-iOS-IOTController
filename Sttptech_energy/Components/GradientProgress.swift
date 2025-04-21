//
//  ProgressBar.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/17.
//

import SwiftUI

/// 溫度控制視圖
struct GradientProgress: View {
    @Binding var currentTemperature: Int // 初始溫度
    @Binding var minTemperature: Int  // 最小溫度
    @Binding var maxTemperature: Int  // 最大溫度 

    @State private var temperature: Int = 0 // UI元件初始溫度（動畫使用）
    @State private var lastHapticTime = Date() // 上次震動的時間

    var body: some View {
        GeometryReader { geometry in
            let barWidth = geometry.size.width * 1.0 // 畫面寬度的 90%
            let totalSegments = (maxTemperature - minTemperature) + 1 // 15 段均分 default:15
            
            ZStack(alignment: .leading) {
                // 背景容器
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.6))
                    .frame(width: barWidth, height: 100)
                //                    .overlay(
                //                           RoundedRectangle(cornerRadius: 12) // 添加邊框
                //                            .stroke(Color.white.opacity(0.4), lineWidth: 4) // 邊框顏色和透明度
                //                       )
                
                // 進度漸層
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 10,
                    bottomLeading: 10,
                    bottomTrailing: cornerRadius(for: temperature, corner: .topRight),
                    topTrailing: cornerRadius(for: temperature, corner: .bottomRight)
                ), style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors(for: temperature)),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: progressWidth(for: barWidth, totalSegments: totalSegments), height: 100)
                //                    .animation(.easeInOut(duration: 0.2), value: temperature) // 添加動畫
                
                // 溫度文字
                Text("\(temperature)°")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .padding(20)
                    .frame(width: barWidth, height: 100, alignment: .leading)
            }
            .shadow(radius: 5)
            .onAppear {
                currentTemperature = min(max(currentTemperature, minTemperature), maxTemperature)
                temperature = currentTemperature
            }
            .onChange(of: currentTemperature, { oldValue, newValue in
                temperature = currentTemperature // 初始化時與 Binding 值同步
            })
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let locationX = value.location.x
                        let clampedX = max(0, min(locationX, barWidth))
                        let segmentWidth = barWidth / CGFloat(totalSegments) // 每段寬度
                        let newTemperature = Int(clampedX / segmentWidth) + minTemperature
                        
                        // 只在溫度值實際改變時觸發震動
                        if temperature != newTemperature {
                            let now = Date()
                            if now.timeIntervalSince(lastHapticTime) > 0.1 { // 至少間隔 100 毫秒
                                triggerHapticFeedback() // 觸發震動
                                lastHapticTime = now
                            }
                            
//                            temperature = min(maxTemperature, max(minTemperature, newTemperature))
                            withAnimation(nil) {
                                temperature = min(maxTemperature, max(minTemperature, newTemperature))
                            }
                        }
                    }
                    .onEnded { _ in
                        // ✅ 只有在用戶停止拖動後才觸發 API 呼叫
                        currentTemperature = temperature // ✅ 結束時再更新
                        print("溫度數據送出：\(currentTemperature)")
                    }
            )
        }
    }
    
    /// 根據溫度範圍選擇對應的漸層顏色
    private func gradientColors(for temperature: Int) -> [Color] {
        switch temperature {
        case 0...17:
            return [Color(hex: "#8DA8E3"), Color(hex: "#B7A8DE")]
        case 18...20:
            return [Color(hex: "#1F9AF4"), Color(hex: "#2267EA")]
        case 21...26:
            return [Color(hex: "#5DC2B8"), Color(hex: "#089B99")]
        case 27...29:
            return [Color(hex: "#FFA700"), Color(hex: "#FF8900")]
        case 30...100:
            return [Color(hex: "#FF8900"), Color(hex: "#FF6C00")]
        default:
            return [Color.gray, Color.gray] // 預設顏色
        }
    }
    
    // 計算進度條的寬度
    private func progressWidth(for barWidth: CGFloat, totalSegments: Int) -> CGFloat {
        let adjustedSegments = totalSegments // 確保分為 15 段
        let progress = CGFloat(temperature - minTemperature + 1) / CGFloat(adjustedSegments)
        print("溫度:", progress)
        return progress * barWidth
    }
    
    /// 設置不同角的圓角半徑
    private func cornerRadius(for temperature: Int, corner: CornerType) -> CGFloat {
        if temperature == 30 {
            return 10 // 四個角都是20
        } else {
            switch corner {
            case .topLeft, .bottomLeft:
                return 10
            case .topRight, .bottomRight:
                return 0
            }
        }
    }
}

