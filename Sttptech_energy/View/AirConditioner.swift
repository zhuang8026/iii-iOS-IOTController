//
//  AirConditioner.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/20.
//

import SwiftUI

struct AirConditioner: View {
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    @State private var roomData: RoomData?
    
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    @State private var isPowerOn = false
    @State private var selectedMode = 0
    @State private var fanSpeed: Double = 1.0
    @State private var temperature: Int = 25
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    /// HStack 控制水平排列，VStack 控制垂直排列
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if let roomData = roomData {
                    PowerToggle(isPowerOn: $isPowerOn) {
                        triggerAPI(for: "power_rw")
                    }
                    
                    if isPowerOn {
                        /// 風速和空調溫度顯示
                        ACnumber(fanSpeed:$fanSpeed, temperature: $temperature)
                        
                        /// 模式
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                // tag
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                Text("模式")
                            }
                            ModeSelector(selectedMode: $selectedMode) {
                                triggerAPI(for: "op_mode_rw")
                            }
                        }
                        
                        /// 風速
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                // tag
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                Text("風速")
                            }
                            FanSpeedSlider(fanSpeed: $fanSpeed) { /// 風速控制
                                triggerAPI(for: "fan_level_rw")
                            }
                        }
                        
                        /// 溫度
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                // tag
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                Text("溫度")
                            }
                            GradientProgress(currentTemperature: $temperature) {  /// 溫度控制視圖
                                triggerAPI(for: "temperature_cfg_rw")
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
                } else {
                    Spacer()
                    Loading(text: "檢查設備")
                    Spacer()
                }
                
                
                if appStore.showPopup {
                    CustomPopupView(isPresented: $appStore.showPopup, title: $appStore.title, message: $appStore.message)
                        .transition(.opacity) // 淡入淡出效果
                        .zIndex(1) // 確保彈窗在最上層
                }
            }
            .animation(.easeInOut, value: appStore.showPopup)
            // 🔥 監聽 isPowerOn 的變化
            .onChange(of: isPowerOn) { prevVal, nextVal in
                if nextVal {
                    appStore.showPopup = true // 開啟提示窗
                }
            }
            .onAppear {
                Task {
                    roomData = try await apiService.apiGetAirConditionerInfo() // ✅ 取得設備資料
                    guard let ac = roomData?.ac else { return }
                    
                    print("GET-API-AC:", ac)
                    // 先暫時解除綁定，避免觸發 POST API
                    let tempPowerOn = ac.power_rw == "1"
                    let tempSelectedMode = Int(ac.op_mode_rw) ?? 0
                    let tempTemperature = Int(ac.temperature_cfg_rw) ?? 16
                    let tempFanSpeed = Double(ac.fan_level_rw) ?? 1.0
                    
                    // 設定值後，這時候還不會觸發 onChange
                    isPowerOn = tempPowerOn
                    selectedMode = tempSelectedMode
                    temperature = tempTemperature
                    fanSpeed = tempFanSpeed
                }
            }
        }
        //        .onChange(of: isPowerOn) { _, _ in triggerAPI(for: "power_rw") }
        //        .onChange(of: selectedMode) { _, _ in triggerAPI(for: "op_mode_rw") }
        //        .onChange(of: temperature) { _, _ in triggerAPI(for: "temperature_cfg_rw") }
        //        .onChange(of: fanSpeed) { _, _ in triggerAPI(for: "fan_level_rw") }
    }
    
    // 🔥 提取 API 呼叫邏輯
    func triggerAPI(for key: String) {
        Task {
            await sendAirConditionerSettings(for: key)
        }
    }
    
}


extension AirConditioner {
    func sendAirConditionerSettings(for key: String) async {
        guard isConnected else {
            print("⚠️ 設備未連線，無法送出設定")
            return
        }
        
        var payload: [String: Any] = [:]
        
        switch key {
        case "power_rw":
            payload = ["ac": ["power_rw": isPowerOn ? "1" : "0"]]
        case "op_mode_rw":
            payload = ["ac": ["op_mode_rw": String(selectedMode)]]
        case "temperature_cfg_rw":
            payload = ["ac": ["temperature_cfg_rw": String(temperature)]]
        case "fan_level_rw":
            payload = ["ac": ["fan_level_rw": String(Int(fanSpeed))]]
        default:
            return
        }
        
        print("PAYLOAD-AC:\(payload)")
        
        do {
            if let response = try await apiService.apiPostSettingAirConditioner(payload: payload) {
                print("✅ 冷氣 API 回應: \(response)")
            } else {
                print("❌ API 回應失敗")
            }
        } catch {
            print("❌ 發送請求時出錯: \(error)")
        }
    }
}
