//
//  PopupWindow.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/26.
//

import SwiftUI

struct CustomPopupView: View {
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    @Binding var isPresented: Bool  // 控制提示視窗顯示
    @Binding var title: String // title
    @Binding var message: String // content
    
    // 移除黑色透明背景
    private func removeDimmingView(isCheck: Bool) {
        appStore.isAIControl = isCheck
        withAnimation {
            isPresented = false
        }
        
        // AI決策推播測試
        if isCheck {
            sendLocalNotification(title: appStore.title, body: appStore.notificationsResult)
        }
    }

    var body: some View {
        ZStack {
            // 半透明黑色背景，擋住點擊事件
            Color.black.opacity(0)
                .edgesIgnoringSafeArea(.all) // 覆蓋整個螢幕
                .transition(.opacity) // 添加淡入淡出效果
                .animation(.easeInOut, value: true)
                .onTapGesture { } // 阻止点击事件穿透
                .allowsHitTesting(false) // 禁用所有触摸事件，防止触发按钮缩放
            
            // 警告框 (Alert)
                .alert("\(title)", isPresented: $isPresented) {
                    Button("確認", role: .none) {
                        removeDimmingView(isCheck: true)
                        print("用戶按了確認")
                    }
                    Button("取消", role: .cancel) {
                        removeDimmingView(isCheck: false)
                        print("用戶按了取消")
                    }
                } message: {
                    Text("\(message)")
                }
        }
        
    }
}
