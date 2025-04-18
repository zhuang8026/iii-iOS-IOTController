//
//  ContentView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mqttManager: MQTTManager // 從環境取得 MQTTManager
    
    @State private var selectedTab = "" // 選擇設備控制
    @State private var status = false // 控制顯示標題名稱（內含 返回 icon）
    @State private var isShowingSmartControl = false // [pop-up] 是否要開始 智慧環控連線 頁面，默認：關閉
    @State private var isSmartControlConnected = true // [status] 連線狀態，默認：API GET 告知
    
    //    @AppStorage("isTempConnected")
    @State private var isTempConnected = true   // ✅ 溫濕度 記住連線狀態
    //    @AppStorage("isACConnected")
    @State private var isACConnected = false    // ✅ 冷氣 記住連線狀態
    //    @AppStorage("isDFConnected")
    @State private var isDFConnected = false     // ✅ 除濕機 記住連線狀態
    //    @AppStorage("isREMCConnected")
    @State private var isREMCConnected = true   // ✅ 遙控器 記住連線狀態
    //    @AppStorage("isESTConnected")
    @State private var isESTConnected = true    // ✅ 插座 記住連線狀態
    
    // 根據 selectedTab 動態決定 `status`
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
    
    // 判斷MQTT是否有資料
    // 1. update = nil -> true
    // 2. sensor = nil -> true
    private func isMQTTManagerLoading(tab: String) -> Bool {
        switch tab {
            case "溫濕度":
                return mqttManager.appliances["sensor"] == nil
            case "空調":
                return mqttManager.appliances["air_conditioner"] == nil
            case "除濕機":
                return mqttManager.appliances["dehumidifier"] == nil
            case "遙控器":
                return false
            case "插座":
                return false
            default:
                return false
        }
    }
    
    /// 根據 tab 判斷對應裝置是否在 30 分鐘內有更新（即是否在線）
    /// - Parameter tab: UI 分頁名稱，例如 "溫濕度"
    /// - Returns: 若裝置在 30 分鐘內有回傳資料，回傳 true（在線），否則 false（離線）
    /// - Returns: 畫面正常 (true)、設備未連線 (false)
    private func isDeviceUpdatedOnline(tab: String) -> Bool {
        // 將 tab 名稱對應到實際裝置的 MQTT key
        let tabToDeviceKey: [String: String] = [
            "溫濕度": "sensor",
            "空調": "air_conditioner",
            "除濕機": "dehumidifier",
            "遙控器": "remote"
        ]

        // 取得對應 MQTT 裝置資料（deviceData 為 [String: ApplianceData]）
        guard let deviceKey = tabToDeviceKey[tab],
              let deviceData = mqttManager.appliances[deviceKey],
              let updatedTime = deviceData["updated"] else {
            // 若找不到 key 或資料，視為離線
            return false
        }

        // 建立 ISO8601 格式的解析器（支援毫秒）
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // 將 updated 字串轉為 Date 物件（若格式錯誤則離線）
        guard let updatedDate = formatter.date(from: updatedTime.updated) else {
            return false
        }

        // 取得目前時間與更新時間的差距（秒）
        let now = Date()
        let timeInterval = now.timeIntervalSince(updatedDate)
        
        // 若差距在 30 分鐘內，代表在線，否則離線
        return timeInterval <= 1800 // 30分鐘 = 1800秒
    }

    
    var body: some View {
        VStack(spacing: 20) {
            // ✅ 傳遞 selectedTab 和 status
            HeaderName(selectedTab: $selectedTab, status: bindingForSelectedTab())
            
            // 測試使用，可去除
            // Text(mqttManager.loginResponse ?? "等待登入回應...")
            if(isSmartControlConnected) {
                VStack() {
                    ZStack() {
                        /// ✅ 設備已連線
                        VStack() {
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
                                    Spacer()
                                    Loading(text: "Loading..")
                                    Spacer()
                            }
                            
                        }
                        // ❌ 無資料 → 顯示 Loading 畫面
                        if isMQTTManagerLoading(tab: selectedTab) {
                            Color.light_green.opacity(0.75) // 透明磨砂黑背景
                                .edgesIgnoringSafeArea(.all) // 覆蓋整個畫面
                            Loading(text: "載入\(selectedTab)資料中...",color: Color.g_blue)
                        }
                    }
                    
                    

    
                    Spacer()
                    
                    // 底部導航欄
                    NavigationBar(selectedTab: $selectedTab)
                        .environmentObject(mqttManager) // 確保能讀取 availables
                }
            } else {
                /// ✅ 智能環控 連結
                AddSmartControlView(
                    isShowingSmartControl: $isShowingSmartControl,  // 是否要開始 智慧環控連線 頁面，默認：關閉
                    isConnected: $isSmartControlConnected // 連線狀態
                )
            }
            
            
        }
        .padding()
        .background(Color.light_green.opacity(1))
        .onAppear {
            mqttManager.connectMQTT() // 當 isConnected 變為 true，啟動 MQTT
        }
        .onDisappear {
            mqttManager.disconnectMQTT() // 離開畫面 斷開 MQTT 連線
        }
        .onChange(of: mqttManager.isConnected) { oldConnect, newConnect in
            // 連線MQTT
            if newConnect {
                //                mqttManager.publishApplianceUserLogin(username: "app", password: "app:ppa")
                mqttManager.publishTelemetryCommand(subscribe: true)
            }
        }
        .onReceive(mqttManager.$isSmartBind) { newValue in
//            isSmartControlConnected = newValue
        }
    }
}

//#Preview {
//    ContentView()
//}
