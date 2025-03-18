//
//  HeaderView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/20.
//

import SwiftUI

/// 頂部標題視圖
struct HeaderName: View {
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    @Binding var selectedTab: String // 標題名稱
    @Binding var status: Bool // 是否要顯示返回（false -> back, true -> show title）
    @State private var isAnimating = false // 動畫
    
    var body: some View {
        HStack {
            if status {
                Image("arrow-left") // 改成返回按鈕
                    .font(.system(size: 20))
                Spacer()
                
                // [顯示] 是否啟動AI決策
                if (appStore.isAIControl) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("AI決策執行中")
                            .font(.system(size: 14))
                            .foregroundColor(Color.g_blue)
                    }
                    .frame(height: 30.0)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .background(Color.white) // 讓霓虹燈更明顯
                    .cornerRadius(100.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]),
                                    center: .center,
                                    angle: .degrees(isAnimating ? 360 : 0)
                                ),
                                lineWidth: 4
                            )
                            .blur(radius: 3) // 模糊效果，讓光暈更自然
                    )
                    .shadow(color: Color.red.opacity(0.6), radius: 10, x: 0, y: 0) // 給予光暈
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                            isAnimating.toggle()
                        }
                    }
                    .onTapGesture {
                        print("AI決策: \(appStore.showPopup)")
                        withAnimation {
                            appStore.showPopup = true // ⚡ 點擊後改變狀態
                            appStore.title = "中斷AI決策"
                            appStore.message = "是否中斷AI決策?"
                        }
                    }
                } else {
                    Text("\(selectedTab)設定")
                        .font(.body)
                }
                
                Spacer()
                Image(systemName: "trash") // 垃圾桶
                    .foregroundColor(Color.blue) // 確保顏色存在
                    .font(.system(size: 20)) // 調整圖示大小
                    .onTapGesture {
                        status = false // ✅ 點擊後切換 status
                    }
            } else {
                Image("arrow-left") // 改成返回按鈕
                    .font(.system(size: 20))
                    .onTapGesture {
                        status = true // ✅ 點擊後切換 status
                    }
                
                Spacer() // 推動其他內容到右側
            }
        }
        .frame(height: 30.0)
        
    }
}
