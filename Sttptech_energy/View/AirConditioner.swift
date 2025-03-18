//
//  AirConditioner.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/20.
//

import SwiftUI

struct AirConditioner: View {
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager

    @State private var isPowerOn = true
    @State private var selectedMode = "cool"
    @State private var fanSpeed: String = "auto"
    @State private var temperature: Int = 24
    @State private var modes = ["cool", "heat", "dry", "fan", "auto"]

    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    /// 解析 MQTT 家電數據，更新 UI
    private func updateAirConditionerData() {
        guard let airConditionerData = mqttManager.appliances["air_conditioner"] else { return }
        
        // 解析 `cfg_power` -> Bool (開 / 關)
        if let power = airConditionerData["cfg_power"]?.value {
            isPowerOn = (power == "on")
        }
        
        // 解析 `cfg_mode` -> String ("cool", "dry", "fan", "auto", "heat")
        if let mode = airConditionerData["cfg_mode"]?.value {
            selectedMode = mode
        }
        
        // 解析 `cfg_fan_level` -> String ("auto", "low", "medium", "high", "strong", "max")
        if let fanLevel = airConditionerData["cfg_fan_level"]?.value {
            fanSpeed = fanLevel
        }

        // 解析 `cfg_temperature` -> Int
        if let temp = airConditionerData["cfg_temperature"]?.value, let tempInt = Int(temp) {
            temperature = tempInt
        }
    
        

    }
    
    /// HStack 控制水平排列，VStack 控制垂直排列
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                PowerToggle(isPowerOn: $isPowerOn)
                
                if isPowerOn {
                    /// 風量和空調溫度顯示
//                    ACnumber(fanSpeed:$fanSpeed, temperature: $temperature)
                    
                    /// 模式
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            // tag
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                            Text("模式")
                        }
                        ModeSelector(selectedMode: $selectedMode, modes: $modes)
                    }
                    
                    /// 風量
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            // tag
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                            Text("風速")
                        }
//                        FanSpeedSlider(fanSpeed: $fanSpeed) /// 風量控制
                        WindSpeedView(selectedSpeed: $fanSpeed) // 風速控制
                    }
                    
                    /// 溫度
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // tag
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                            Text("溫度")
                        }
                        GradientProgress(currentTemperature: $temperature) /// 溫度控制視圖
                    }
                    
                } else {
                    /// 請開始電源
                    VStack {
                        Spacer()
                        Image("open-power-hint")
                        Text("請先啟動設備")
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if appStore.showPopup {
                    CustomPopupView(isPresented: $appStore.showPopup, title: $appStore.title, message: $appStore.message)
                        .transition(.opacity) // 淡入淡出效果
                        .zIndex(1) // 確保彈窗在最上層
                }
            }
            .animation(.easeInOut, value: appStore.showPopup)
            // 🔥 監聽 isPowerOn 的變化
            .onChange(of: isPowerOn) { oldVal, newVal in
                print(oldVal, newVal)
                if newVal {
                    appStore.showPopup = true // 開啟提示窗
                }
            }
            .onAppear {
                updateAirConditionerData() // 畫面載入時初始化數據
            }
//            .onChange(of: mqttManager.appliances["dehumidifier"]?.id) { _ in
//                updateDehumidifierData()
//            }
            .onChange(of: mqttManager.appliances["air_conditioner"]) { _, _ in
                updateAirConditionerData()
            }
        }
    }
}

//#Preview {
//    AirConditioner()
//}
