//
//  Temperature.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Temperature: View {
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager
    
    @State private var isShowingNewDeviceView = false // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab = "溫濕度"
    
    //    @AppStorage("isConnected") private var isConnected = false // ✅ 記住連線狀態
    
    var body: some View {
        if (isConnected) {
            /// ✅ 設備已連線
            VStack(spacing: 9) {
                // 取得 sensor 數據
                let sensorData = mqttManager.appliances["sensor"]
                let humidity = (sensorData?["op_humidity"]?.value).flatMap { Double($0) } ?? 0.0
                let progress = humidity / 100.0 // ✅ 轉換成 0 ~ 1 之間的數值
                
                // 轉換 temperature 和 co2，並四捨五入為整數
                let temperature = (sensorData?["op_temperature"]?.value).flatMap { Double($0) }
                    .map { String(Int($0.rounded())) } ?? "--"
                
                let co2 = (sensorData?["op_co2"]?.value).flatMap { Double($0) }
                    .map { String(Int($0.rounded())) } ?? "--"
                
                Spacer()
                // ✅ 顯示濕度進度條
                CircularProgressBar(progress: progress)
                Spacer()
                // ✅ 顯示溫度 & CO2 數據
                EnvironmentalCardView(temperature: temperature, co2: co2)
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
