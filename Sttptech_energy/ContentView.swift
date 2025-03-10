//
//  ContentView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/14.
//

import SwiftUI

struct ContentView: View {
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    @State private var selectedTab = "溫濕度"
    @State private var status = false // 控制顯示標題名稱（內含 返回 icon）
    
    //    @AppStorage("isTempConnected") private var isTempConnected = true  // ✅ 溫濕度 記住連線狀態
    @State private var isTempConnected: Bool = true  // ✅ 溫濕度 記住連線狀態
    @State private var isACConnected: Bool = true      // ✅ 冷氣 記住連線狀態
    @State private var isDFConnected: Bool = true      // ✅ 除濕機 記住連線狀態
    @State private var isREMCConnected: Bool = true  // ✅ 遙控器 記住連線狀態
    @State private var isESTConnected: Bool = true    // ✅ 插座 記住連線狀態
    
    // ✅ 根據 selectedTab 動態決定 `status`
    private func bindingForSelectedTab() -> Binding<Bool> {
        switch selectedTab {
        case "溫濕度":
            return $isTempConnected
        case "空調":
            return $isACConnected
        case "除濕機":
            return $isDFConnected
        case "遙控器":
            return $isREMCConnected
        case "插座":
            return $isESTConnected
        default:
            return .constant(false)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // ✅ 傳遞 selectedTab 和 status
                HeaderName(selectedTab: $selectedTab, status: bindingForSelectedTab())
                
                // 根據 selectedTab 顯示對應元件
                switch self.selectedTab {
                case "溫濕度":
                    Temperature(isConnected: $isTempConnected)
                case "空調":
                    AirConditioner(isConnected: $isACConnected)
                case "除濕機":
                    Dehumidifier(isConnected: $isDFConnected)
                case "遙控器":
                    RemoteControl(isConnected: $isREMCConnected)
                case "插座":
                    ElectricSocket()
                default:
                    Text("未定義的功能") // 處理未預期的選項
                }
                
                Spacer()
                
                NavigationBar(selectedTab: $selectedTab)
                
            }
            .padding()
            .background(Color.light_green.opacity(1))
            
            if appStore.showPopup {
                CustomPopupView(isPresented: $appStore.showPopup, title: $appStore.title, message: $appStore.message)
                    .transition(.opacity) // 淡入淡出效果
                    .zIndex(1) // 確保彈窗在最上層
            }
        }
    }
}

#Preview {
    ContentView()
}
