//
//  Temperature.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Temperature: View {
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    @State private var roomData: RoomData?
    
    @State private var isShowingNewDeviceView = false // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab = "溫濕度"
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    var body: some View {
        if (isConnected) {
            /// 🟢 設備已「連線」
            VStack(spacing: 9) {
                Spacer()
                if let roomData = roomData {
                    if let humidity = Double(roomData.sensor.humidity_r) {
                        CircularProgressBar(progress: humidity / 100.0)
                    } else {
                        // 处理无法将 temperature_r 转换为 Double 的情况
                        CircularProgressBar(progress: 0.0)
                    }
                    Spacer()
                    EnvironmentalCardView(co2: "1631", temperature: roomData.sensor.temperature_r)
                } else {
                    Loading(text: "檢查設備")
                    //                    CircularProgressBar(progress: 0.0)
                    Spacer()
                    //                    EnvironmentalCardView(co2: "0", temperature:"0")
                }
            }
            .onAppear {
                Task {
                    roomData = try await apiService.apiGetTemperatureInfo() // ✅ 自動載入設備資料
                    //                    print("roomData:\(roomData.sensor)")
                }
            }
            
        } else {
            /// 🔴 設備已「斷線」
            AddDeviceView(
                isShowingNewDeviceView: $isShowingNewDeviceView,
                selectedTab: $selectedTab,
                isConnected: $isConnected // 連線狀態
            )
        }
    }
}

