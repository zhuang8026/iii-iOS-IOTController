//
//  Dehumidifier.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Dehumidifier: View {
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager
    
    // 選項列表
    let humidityOptions = Array(stride(from: 30, through: 90, by: 1)) // 40% - 80%
    let timerOptions = Array(1...24) // 1 - 12 小時
    let waterLevelOptions = ["正常", "滿水"]
    let modeOptions = ["自動除濕", "連續除濕"]
    
    // 選項結果
    @State private var isPowerOn = true
    @State private var selectedMode: String = "自動除濕"  // ["自動除濕", "連續除濕"]
    @State private var selectedHumidity: Int = 50
    @State private var selectedTimer: Int = 2
    @State private var checkWaterFullAlarm: String = "正常" // ["正常", "滿水"]
    @State private var fanSpeed: Double = 2

    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    /// 解析 MQTT 家電數據，更新 UI
    private func updateDehumidifierData() {
        guard let dehumidifierData = mqttManager.appliances["dehumidifier"] else { return }
        
        // 解析 `cfg_power` -> Bool (開 / 關)
        if let power = dehumidifierData["cfg_power"]?.value {
            isPowerOn = (power == "on")
        }
        
        // 解析 `cfg_mode` -> String ("auto" -> "自動除濕", "continuous" -> "連續除濕")
        if let mode = dehumidifierData["cfg_mode"]?.value {
            selectedMode = (mode == "auto") ? "自動除濕" : "連續除濕"
        }
        
        // 解析 `cfg_humidity` -> Int
        if let humidity = dehumidifierData["cfg_humidity"]?.value, let humidityInt = Int(humidity) {
            selectedHumidity = humidityInt
        }
        
        // 解析 `cfg_humidity` -> Int
        if let timer = dehumidifierData["cfg_timer"]?.value, let timerInt = Int(timer) {
            selectedTimer = timerInt
        }

        // 解析 `op_water_full_alarm` -> String ("0" -> "正常", "1" -> "滿水")
        if let waterAlarm = dehumidifierData["op_water_full_alarm"]?.value {
            checkWaterFullAlarm = (waterAlarm == "1") ? "滿水" : "正常"
        }
    }
    
    var body: some View {
        ZStack {
            // 取得 dehumidifier 數據
            //            let DHFRData = mqttManager.appliances["dehumidifier"]
            
            VStack(spacing: 20) {
                PowerToggle(isPowerOn: $isPowerOn)
                if isPowerOn {
                    /// 設定
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            // tag
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                            Text("設定")
                        }
                        HStack() {
                            // 自訂除濕
                            VStack(alignment: .center, spacing: 10) {
                                Text("自訂除濕")
                                HStack {
                                    // Picker 替換 "當前選擇值"，並監聽選擇狀態
                                    Picker("選擇濕度", selection: $selectedHumidity) {
                                        ForEach(humidityOptions, id: \.self) { value in
                                            Text("\(value) %").tag(value)
                                        }
                                    }
                                    .tint(Color.g_blue) // 🔴 修改點擊時的選單顏色
                                    .pickerStyle(MenuPickerStyle()) // 下拉選單
                                    .onChange(of: selectedHumidity) { // ✅ iOS 17 兼容
                                        
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 60.0)
                                .background(Color.light_gray)
                                .cornerRadius(5)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 定時 (Picker)
                            VStack(alignment: .center, spacing: 10) {
                                Text("定時")
                                HStack() {
                                    Picker("選擇時間", selection: $selectedTimer) {
                                        ForEach(timerOptions, id: \.self) { value in
                                            Text("\(value) 小時").tag(value)
                                                .foregroundColor(Color.g_blue)
                                        }
                                    }
                                    .tint(Color.g_blue) // 🔴 修改點擊時的選單顏色
                                    .pickerStyle(MenuPickerStyle()) // 下拉選單
                                }
                                .frame(maxWidth: .infinity, minHeight: 60.0)
                                .background(Color.light_gray)
                                .cornerRadius(5)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 水位 (Picker)
                            VStack(alignment: .center, spacing: 10) {
                                Text("水位")
                                HStack() {
                                    Text("\(checkWaterFullAlarm)")
                                }
                                .frame(maxWidth: .infinity, minHeight: 60.0)
                                .background(Color.light_gray)
                                .cornerRadius(5)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    /// 模式
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            // tag
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                            Text("模式")
                        }
                        
                        // 模式選擇
                        HStack(spacing: 8) { // 調整間距
                            ForEach(modeOptions, id: \.self) { mode in
                                Button(action: {
                                    selectedMode = mode
                                }) {
                                    Text(mode)
                                        .font(.body)
                                        .frame(maxWidth: .infinity, minHeight: 60.0)
                                        .background(selectedMode == mode ? .g_blue : Color.light_gray)
                                        .foregroundColor(selectedMode == mode ? .white : Color.heavy_gray)
                                }
                                //                        .buttonStyle(NoAnimationButtonStyle()) // 使用自訂樣式，完全禁用動畫
                                .cornerRadius(10)
                                .shadow(color: selectedMode == mode ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                            }
                        }
                        //                .aspectRatio(5, contentMode: .fit) // 根據按鈕數量讓高度自適應寬度
                    }
                    
                    /// 風速
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            // tag
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                            Text("風速")
                        }
                        FanSpeedSlider(fanSpeed: $fanSpeed) /// 風速控制
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
//            .onChange(of: isPowerOn) { oldVal, newVal in
//                print(oldVal, newVal)
//                if newVal {
//                    appStore.showPopup = true // 開啟提示窗
//                }
//            }
            .onAppear {
                updateDehumidifierData() // 畫面載入時初始化數據
            }
//            .onChange(of: mqttManager.appliances["dehumidifier"]) { _ in
//                updateDehumidifierData() // 當 MQTT 資料變更時更新 UI
//            }
            
        }
    }
    
}

#Preview {
    Dehumidifier()
}
