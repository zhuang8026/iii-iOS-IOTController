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
    @EnvironmentObject var mqttManager: MQTTManager // 從環境取得 MQTTManager

    @Binding var selectedTab: String // 標題名稱
    @Binding var status: Bool // 是否要顯示返回（false -> back, true -> show title）
    @State private var isAnimating = false // AI決策動畫
    @State private var showPopup = false //
    
    // 判斷是否為"空調", "除濕機" -> true
    private func showDeleteIconSetting(tab: String) -> Bool {
        return ["空調", "除濕機"].contains(tab)
    }
    
    var body: some View {
        HStack {
            if status {
                // 改成返回按鈕
                Image("arrow-left")
                    .font(.system(size: 20))
                
                Spacer()
                
                // [顯示] 是否啟動AI決策
                if (mqttManager.decisionEnabled) {
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
                } else {
                    Text("\(selectedTab)設定")
                        .font(.body)
                }
                
                Spacer()
                
                // 右側垃圾桶或透明佔位符
                if (showDeleteIconSetting(tab: selectedTab)) {
                    Button(action: {
                        showPopup = true
                    }) {
                        Image(systemName: "trash") // 垃圾桶
                            .font(.system(size: 20)) // 調整圖示大小
                            .foregroundColor(Color.g_blue) // 確保顏色存在
                            .contentShape(Rectangle()) // 🔧 指定觸控區形狀，避免預設 highlight
                            .background(Color.clear) // 🔧 確保不會有點擊背景效果
                            .overlay {
                                // [全局][自訂彈窗] 提供空調 與 遙控器 頁面使用
                                if showPopup {
                                    CustomPopupView(
                                        isPresented: $showPopup, // 開關
                                        title: "重新連線",
                                        message:  "是否需重新連線?",
                                        onConfirm: {
                                            showPopup = false // 關閉視窗
                                            status = false // 回到 新增畫面
                                        },
                                        onCancel: {
                                            showPopup = false // 關閉視窗
                                            status = true // 保持畫面
                                            
                                        }
                                    )
                                }
                            }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    // 👇透明佔位符佔住空間，保持中心對齊
                    Image(systemName: "trash")
                        .opacity(0) // 完全透明
                        .font(.system(size: 20)) // 調整圖示大小
                }
            } else {
                // 返回上一層
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
