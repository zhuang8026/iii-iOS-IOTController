//
//  Temperature.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Temperature: View {
    @StateObject private var mqttManager = MQTTManager() // MQTT
    
    @State private var isShowingNewDeviceView = false // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab = "溫濕度"
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    //    @AppStorage("isConnected") private var isConnected = false // ✅ 記住連線狀態
    
    var body: some View {
        Text(mqttManager.loginResponse ?? "等待登入回應...")
        if (isConnected) {
            /// ✅ 設備已連線
            VStack(spacing: 9) {
                Spacer()
                CircularProgressBar(progress: 0.75)
                Spacer()
                EnvironmentalCardView()
            }
            .onAppear {
                mqttManager.connectMQTT() // 當 isConnected 變為 true，啟動 MQTT
            }
            .onDisappear {
                mqttManager.disconnectMQTT() // 離開畫面 斷開 MQTT 連線
            }
            .onChange(of: mqttManager.isConnected) { oldConnect, newConnect in
                // 連線MQTT
                if newConnect {
                    mqttManager.publishLogin(username: "user", password: "user+user")
                }
            }
        } else {
            /// ✅ 設備已斷線
            AddDeviceView(
                isShowingNewDeviceView: $isShowingNewDeviceView,
                selectedTab: $selectedTab,
                isConnected: $isConnected // 連線狀態
            )
        }
    }
}

//
//#Preview {
//    Temperature(isConnected: .constant(false))
//}
