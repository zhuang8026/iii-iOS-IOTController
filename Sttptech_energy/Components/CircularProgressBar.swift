//
//  CircularProgressBar.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/23.
//

import SwiftUI

struct CircularProgressBar: View {
    @State private var animatedProgress: Double = 0.0 // 用於動畫的 progress
    
    var progress: Double // 0.0 到 1.0 的值
    let crcleWidth: Int = 30
    // 外圓的大小，動態計算
    var outSize: CGFloat {
        UIScreen.main.bounds.width * 0.7 // 畫面寬度的 70%
    }
    // 內圓的大小，基於外圓計算
    var inSize: CGFloat {
        outSize * 0.9 // 內圓大小為外圓的 90%
    }
    // 內圓的大小，基於外圓計算
    var fontSize: CGFloat {
        inSize * 0.35 // 內圓大小為外圓的 30%
    }
    
    var body: some View {
        ZStack {
            // 背景圓圈
            Circle()
                .stroke(lineWidth: CGFloat(crcleWidth))
                .foregroundColor(Color.white.opacity(1))
            
            // 前景進度圈
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [Color.g_blue, Color(hex:"#4594B4")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: CGFloat(crcleWidth), lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // 進度條從頂部開始
                .animation(.easeInOut(duration: 1.0), value: animatedProgress) // 動畫效果
            
            // 百分比文字和標籤（圓形區塊）
            ZStack {
                Circle()
                    .fill(Color.light_green) // 圓形背景
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: -4, y: 4) // 陰影效果
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4) // 白色邊框
                    )
                
                VStack {
//                    Text("\(Int(progress * 100))%")
                    Text("\( Int((progress * 100).rounded()) )%")
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(Color(hex:"#4594B4"))
                    
                    Text("溫濕度比例")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: inSize, height: inSize) // 調整文字圓形區塊大小
        }
        //        .padding(40)
        .frame(width: outSize, height: outSize) // 設定高度為螢幕寬度的 80%
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress // 當畫面出現時觸發動畫
            }
        }
        // 🔥 監聽 isPowerOn 的變化
        .onChange(of: progress) { _, _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress // 當畫面出現時觸發動畫
            }
        }
    }
}
