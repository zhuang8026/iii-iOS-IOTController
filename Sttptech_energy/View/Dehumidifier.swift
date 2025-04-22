//
//  Dehumidifier.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Dehumidifier: View {
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    // 控制提示
//    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager
    
    // 選項列表
    let humidityOptions = Array(stride(from: 1, through: 100, by: 1)) // 設定：40% - 80%
    let timerOptions = Array(1...100) // 設定：1 - 12 小時
    let waterLevelOptions = ["正常", "滿水"]
    let modeOptions = [
        "auto", "manual", "continuous", "clothes_drying",
        "purification", "sanitize", "fan", "comfort", "low_drying"
    ]
    
    // 選項結果
    @State private var isPowerOn = true
    @State private var selectedMode: String = "auto"  // ["自動除濕", "連續除濕"]
    @State private var selectedHumidity: Int = 50
    @State private var selectedTimer: Int = 2
    @State private var checkWaterFullAlarm: String = "正常" // ["正常", "滿水"]
    @State private var fanSpeed: String = "auto" // 風速設定變數-> API cfg_fan_level
    
    // 藍芽連線顯示
    @State private var isShowingNewDeviceView = false // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab = "除濕機"
    
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
            selectedMode = mode
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
        
        // 解析 `op_water_full_alarm` -> String ("0" -> "正常", "1" -> "滿水")
        if let fanLevel = dehumidifierData["cfg_fan_level"]?.value {
            fanSpeed = fanLevel
        }
    }
    
    /// **模式轉換函式**
    private func verifyMode(_ mode: String) -> String {
        switch mode {
        case "auto": return "自動除濕"
        case "manual": return "自訂除濕"
        case "continuous": return "連續除濕"
        case "clothes_drying": return "強力乾衣"
        case "purification": return "空氣淨化"
        case "sanitize": return "防霉抗菌"
        case "fan": return "空氣循環"
        case "comfort": return "舒適除濕"
        case "low_drying": return "低濕乾燥"
        default: return "其他"
        }
    }
    
    private func postDehumidifierSetting(mode: [String: Any]) {
        let paylod: [String: Any] = [
            "dehumidifier": mode
        ]
        mqttManager.publishSetDeviceControl(model: paylod)
    }
    
    var body: some View {
        if (isConnected) {
            ZStack {
                // 取得 dehumidifier 數據
                // let DHFRData = mqttManager.appliances["dehumidifier"]
                
                VStack(spacing: 20) {
                    PowerToggle(isPowerOn: $isPowerOn)
                    // 🔥 監聽 isPowerOn 的變化
                        .onChange(of: isPowerOn) { oldVal, newVal in
                            print("isPowerOn: \(newVal)")
                            let paylodModel: [String: Any] = ["cfg_power": newVal ? "on" : "off"]
                            postDehumidifierSetting(mode: paylodModel)
                        }
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
                                        .onChange(of: selectedHumidity) { oldVal, newVal in // 🔥 監聽 isPowerOn 的變化
                                            print("selectedHumidity: \(newVal)")
                                            let paylodModel: [String: Any] = ["cfg_humidity": String(newVal)]
                                            postDehumidifierSetting(mode: paylodModel)
                                        }
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
                                        .onChange(of: selectedTimer) { oldVal, newVal in  // 🔥 監聽 isPowerOn 的變化
                                            print("selectedTimer: \(newVal)")
                                            let paylodModel: [String: Any] = ["cfg_timer": String(newVal)]
                                            postDehumidifierSetting(mode: paylodModel)
                                        }
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
                            VStack(alignment: .center, spacing: 10) {
                                HStack() {
                                    Picker("選擇模式", selection: $selectedMode) {
                                        ForEach(modeOptions, id: \.self) { value in
                                            Text(verifyMode(value)) // 顯示轉換後的中文
                                                .tag(value) // 保持原始模式代號，確保 selection 維持一致
                                        }
                                    }
                                    .tint(Color.g_blue) // 🔴 修改點擊時的選單顏色
                                    .pickerStyle(MenuPickerStyle()) // 下拉選單
                                    .onChange(of: selectedMode) { oldVal, newVal in  // 🔥 監聽 isPowerOn 的變化
                                        print("selectedMode: \(newVal)")
                                        let paylodModel: [String: Any] = ["cfg_mode": newVal]
                                        postDehumidifierSetting(mode: paylodModel)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 60.0)
                                .background(Color.light_gray)
                                .cornerRadius(5)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 模式選擇
                            //                        HStack(spacing: 8) { // 調整間距
                            //                            ForEach(modeOptions, id: \.self) { mode in
                            //                                Button(action: {
                            //                                    selectedMode = mode
                            //                                }) {
                            //                                    Text(mode)
                            //                                        .font(.body)
                            //                                        .frame(maxWidth: .infinity, minHeight: 60.0)
                            //                                        .background(selectedMode == mode ? .g_blue : Color.light_gray)
                            //                                        .foregroundColor(selectedMode == mode ? .white : Color.heavy_gray)
                            //                                }
                            //                                //                        .buttonStyle(NoAnimationButtonStyle()) // 使用自訂樣式，完全禁用動畫
                            //                                .cornerRadius(10)
                            //                                .shadow(color: selectedMode == mode ? .blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                            //                            }
                            //                        }
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
                            //  FanSpeedSlider(fanSpeed: $fanSpeed) // 風速控制
                            WindSpeedView(selectedSpeed: $fanSpeed) // 風速控制
                                .onChange(of: fanSpeed) { oldVal, newVal in  // 🔥 監聽 isPowerOn 的變化
                                    print("fanSpeed: \(newVal)")
                                    let paylodModel: [String: Any] = ["cfg_fan_level": newVal]
                                    postDehumidifierSetting(mode: paylodModel)
                                }
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
                }
                .onAppear {
                    updateDehumidifierData() // 畫面載入時初始化數據
                }
                .onChange(of: mqttManager.appliances["dehumidifier"]) { _, _ in
                    updateDehumidifierData()
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
//    Dehumidifier()
//}
