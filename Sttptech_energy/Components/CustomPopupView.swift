//
//  PopupWindow.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/26.
//

import SwiftUI

struct CustomPopupView: View {
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    // MARK: - 控制提示視窗顯示
    @Binding var isPresented: Bool
    
    // MARK: - 父層控制
    var title: String // title
    var message: String // content
    
    // MARK: - 父層使用
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    // 提示窗 確認與否
    //    private func removeDimmingView(isCheck: Bool) {
    //        // [測試][MQTT] isCheck -> true -> 啟動, isCheck -> false -> 關閉
    //        appStore.isAIControl = isCheck
    //
    //        // [測試][推播] AI決策推播測試 -> 未來需刪除 不能放在元件中
    //        if isCheck {
    //            sendLocalNotification(title: title, body: appStore.notificationsResult)
    //        }
    //
    //        // 關閉視窗
    //        withAnimation { isPresented = false }
    //    }
    
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
                        onConfirm()
                        withAnimation { isPresented = false }
                    }
                    Button("取消", role: .cancel) {
                        onCancel()
                        withAnimation { isPresented = false }
                    }
                } message: {
                    Text("\(message)")
                }
        }
        .transition(.opacity) // 淡入淡出效果
        .zIndex(1) // 確保彈窗在最上層
    }
}
