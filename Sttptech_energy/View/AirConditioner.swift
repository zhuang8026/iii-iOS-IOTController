//
//  AirConditioner.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/20.
//

import SwiftUI

struct AirConditioner: View {
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 全局倉庫
//    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager
    
    @State private var isPowerOn = true
    @State private var selectedMode = "cool"
    @State private var fanSpeed: String = "auto"
    @State private var fanModeOptions: [String] = [] // ["auto", "low", "medium", "high", "strong", "max"]
    @State private var temperature: Int = 24
    @State private var minTemp: Int = 16
    @State private var maxTemp: Int = 30
    @State private var modes:[String] = [] // 【"cool", "heat", "dry", "fan", "auto"】
    
    // 藍芽連線顯示
    @State private var isShowingNewDeviceView = false // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab = "空調"

    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    // MARK: - 取得 MQTT 設備讀取能力，更新 UI
    private func checkAirConditionerCapabilities() {
        guard let AC_Capabilities = MQTTManagerMiddle.shared.deviceCapabilities["air_conditioner"] else {
            return
        }
        
        // 解析 `cfg_mode` -> String ("cool", "dry", "fan", "auto", "heat")
        if let modeString = AC_Capabilities["cfg_mode"] {
            let modevalue = modeString.filter {
                $0 != "read"
            }  // ❌ 排除 "read"
            self.modes = modevalue
        }
        
        // 解析 `cfg_fan_level` -> String ("auto", "low", "medium", "high", "strong", "max")
        if let fanLevel = AC_Capabilities["cfg_fan_level"] {
            let filteredFanLevels = fanLevel.filter {
                $0 != "read"
            }  // ❌ 排除 "read"
            fanModeOptions = filteredFanLevels
        }
        
        // 解析 `cfg_temperature` -> Int
        if let tempStrings = AC_Capabilities["cfg_temperature"] {
            let tempValues = tempStrings
                .filter { $0 != "read" }               // ❌ 排除 "read"
                .compactMap { Int($0) }                // ✅ 字串轉 Int
                .filter { $0 >= 0 && $0 <= 100 }       // ✅ 避免不合理值（保險）
            
            self.minTemp = tempValues.min() ?? 16
            self.maxTemp = tempValues.max() ?? 30
        }
    }
    
    // MARK: - 解析 MQTT 家電數據，更新 UI
    private func updateAirConditionerData() {
        guard let airConditionerData = MQTTManagerMiddle.shared.appliances["air_conditioner"] else {
            return
        }
        
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
        if let temp = airConditionerData["cfg_temperature"]?.value, let tempInt = Int(
            temp
        ) {
            temperature = tempInt
        }
    }
    
    // MARK: - POST API
    private func postAirConditionerRemote(mode: [String: Any]) {
        let paylod: [String: Any] = [
            "air_conditioner": mode
        ]
//        mqttManager.publishSetDeviceControl(model: paylod)
        MQTTManagerMiddle.shared.setDeviceControl(model: paylod)
    }
    
    //MARK: - HStack 控制水平排列，VStack 控制垂直排列
    var body: some View {
        if (isConnected) {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    PowerToggle(isPowerOn: $isPowerOn) { newVal in
                        print("AC power: \(newVal)")
                        let paylodModel: [String: Any] = ["cfg_power": newVal ? "on" : "off"]
                        postAirConditionerRemote(mode: paylodModel)
                    }
                    // 🔥 監聽 isPowerOn 的變化
                    // .onChange(of: isPowerOn) { oldVal, newVal in
                    //     print("AC power: \(newVal)")
                    //     let paylodModel: [String: Any] = ["cfg_power": newVal ? "on" : "off"]
                    //     postAirConditionerRemote(mode: paylodModel)
                    // }
                    
                    if isPowerOn {
                        // 風量和空調溫度顯示
                        //                    ACnumber(fanSpeed:$fanSpeed, temperature: $temperature)
                        
                        // 模式
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                // tag
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(
                                        width: titleWidth,
                                        height: titleHeight
                                    ) // 控制長方形的高度，寬度根據內容自動調整
                                Text("模式")
                            }
                            ModeSelector(
                                selectedMode: $selectedMode,
                                modes: $modes
                            )
                            // 🔥 監聽 selectedTab 的變化
                            .onChange(of: selectedMode) {oldVal, newVal in
                                print("送出模式: \(newVal)")
                                let paylodModel: [String: Any] = ["cfg_mode": newVal]
                                postAirConditionerRemote(mode: paylodModel)
                            }
                        }
                        
                        // 風速
                        if(!fanModeOptions.isEmpty) {
                            VStack(alignment: .leading, spacing: 9) {
                                HStack {
                                    // tag
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(
                                            width: titleWidth,
                                            height: titleHeight
                                        ) // 控制長方形的高度，寬度根據內容自動調整
                                    Text("風速")
                                }
                                
                                //                        FanSpeedSlider(fanSpeed: $fanSpeed) /// 風量控制
                                WindSpeedView(selectedSpeed: $fanSpeed, fanMode: $fanModeOptions) // 風速控制
                                // 🔥 監聽 fanSpeed 的變化
                                    .onChange(of: fanSpeed) { oldVal, newVal in
                                        print("送出風速: \(newVal)")
                                        let paylodModel: [String: Any] = ["cfg_fan_level": newVal]
                                        postAirConditionerRemote(mode: paylodModel)
                                    }
                            }
                        }
                        // 溫度
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                // tag
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(
                                        width: titleWidth,
                                        height: titleHeight
                                    ) // 控制長方形的高度，寬度根據內容自動調整
                                Text("溫度")
                            }
                            GradientProgress(
                                currentTemperature: $temperature, // now temp
                                minTemperature: $minTemp, // min temp
                                maxTemperature: $maxTemp  // max temp
                            ) /// 溫度控制視圖
                            // 🔥 監聽 temperature 的變化
                            .onChange(of: temperature) { newVal in
                                print("送出溫度:", newVal)
                                let paylodModel: [String: Any] = ["cfg_temperature": String(newVal)]
                                postAirConditionerRemote(mode: paylodModel)
                            }
                        }
                        
                    } else {
                        /// 請開始電源
                        VStack {
                            Spacer()
                            Image("open-power")
                            Text("請先啟動設備")
                                .font(.body)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .onAppear {
                    checkAirConditionerCapabilities() // 檢查設備可讀取資料
                    updateAirConditionerData()        // 畫面載入時初始化數據
                }
                //            .onChange(of: mqttManager.appliances["dehumidifier"]?.id) { _ in
                //                updateDehumidifierData()
                //            }
                .onChange(
                    of: MQTTManagerMiddle.shared.appliances["air_conditioner"]
                ) { _, _ in
                    updateAirConditionerData()
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

//#Preview {
//    AirConditioner()
//}
