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
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    
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
                CustomPopupView(
                    isPresented: $appStore.showPopup,
                    title: $appStore.title,
                    message: $appStore.message,
                    onConfirm: {  // ✅ 當用戶點擊「確認」時觸發 API
                        Task {
                            do {
                                var payload = try await apiService.apiGetAIControllerInfo() // ✅ 自動載入設備資料 (去除 original_data)
                                payload.socket = ["power_w": "1"] // ✅ 加入 socket
                                // ✅ 修改 air conditioner 的 power_rw
                                var updatedAC = payload.ac
                                updatedAC.power_rw = "1"
                                updatedAC.temperature_cfg_rw = "27"
                                payload.ac = updatedAC
                                
                                // ✅ 修改 Dehumidifier 的 power_rw
                                var updatedDehumidifier = payload.dehumidifier
                                updatedDehumidifier.power_rw = "1"
                                updatedDehumidifier.humidity_cfg_rw = "55"
                                payload.dehumidifier = updatedDehumidifier
    
                                let response = try await apiService.apiPostSettingAIController(payload: payload) // ✅ 發送 API
                                print("API 請求成功: \(response!)")
                            } catch {
                                print("API 請求失敗: \(error)")
                            }
                        }
                    }
                )
                .transition(.opacity) // 淡入淡出效果
                .zIndex(1) // 確保彈窗在最上層
            }
        }
    }
}

#Preview {
    ContentView()
}
