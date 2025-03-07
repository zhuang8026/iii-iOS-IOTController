//
//  Dehumidifier.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Dehumidifier: View {
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    @State private var roomData: RoomData?
    
    @Binding var isConnected: Bool // 設備藍芽是否已連線

    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    @State private var isPowerOn = true
    @State private var fanSpeed: Double = 2
    
    // 選項結果
    @State private var selectedHumidity: Int = 40
    @State private var selectedTimer: Int = 0
    @State private var selectedWaterLevel: String = "正常"
    @State private var selectedMode: String = ""
    
    // 選項列表
    let humidityOptions = Array(stride(from: 40, through: 70, by: 5)) // 40% - 70%
    let timerOptions = Array(0...12) // 1 - 12 小時
    let waterLevelOptions = ["正常", "過低", "滿水"]
    let modeOptions = ["設定除濕", "低濕乾燥"] // 1 & 8
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                if let roomData = roomData {
                    PowerToggle(isPowerOn: $isPowerOn) {
                        triggerAPI(for: "power_rw")
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
                                        .onChange(of: selectedHumidity) { // ✅ iOS 17 兼容 & 變更時觸發 API
                                            _ in
                                            triggerAPI(for: "humidity_cfg_rw")
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
                                        Text("正常")
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
                            .onChange(of: selectedMode) { _ in // ✅ iOS 17 兼容 & 變更時觸發 API
                                triggerAPI(for: "op_mode_rw")
                            }
                            
                        }
                        
                        /// 風速
                        //                    VStack(alignment: .leading, spacing: 9) {
                        //                        HStack {
                        //                            // tag
                        //                            RoundedRectangle(cornerRadius: 4)
                        //                                .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                        //                            Text("風速")
                        //                        }
                        //                        FanSpeedSlider(fanSpeed: $fanSpeed) /// 風速控制
                        //                    }
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
            .onChange(of: isPowerOn) { oldVal, newVal in
                //                print(oldVal, newVal)
                if newVal {
                    appStore.showPopup = true // 開啟提示窗
                }
            }
            .onAppear {
                Task {
                    roomData = try await apiService.apiGetDehumidifierInfo() // ✅ 取得設備資料

                    guard let dehumidifier = roomData?.dehumidifier else { return }
                    print("GET-API-DFR:", dehumidifier)
                    // 先暫時解除綁定，避免觸發 POST API
                    let tempPowerOn = dehumidifier.power_rw == "1"
                    let tempHumidity = Int(dehumidifier.humidity_cfg_rw) ?? 50
                    let tempMode = (dehumidifier.op_mode_rw == "1") ? "設定除濕" : "低濕乾燥" // 1:設定除濕, 8:低濕乾燥

                    // 設定值後，這時候還不會觸發 onChange
                    isPowerOn = tempPowerOn
                    selectedHumidity = tempHumidity
                    selectedMode = tempMode
                }
            }
        }
    }
    
    // 🔥 提取 API 呼叫邏輯
    func triggerAPI(for key: String) {
        Task {
            await sendDehumidifierSettings(for: key)
        }
    }

}

extension Dehumidifier {
    func sendDehumidifierSettings(for key: String) async {
        guard isConnected else {
            print("⚠️ 設備未連線，無法送出設定")
            return
        }
        
        var payload: [String: Any] = [:]
        
        switch key {
            case "power_rw":
                payload = ["dehumidifier": ["power_rw": isPowerOn ? "1" : "0"]]
            case "op_mode_rw":
                payload = ["dehumidifier": ["op_mode_rw": selectedMode == "設定除濕" ? "1" : "8"]]
            case "humidity_cfg_rw":
                payload = ["dehumidifier": ["humidity_cfg_rw": String(selectedHumidity)]]
            default:
                return
        }
        
        print("PAYLOAD-DFR:\(payload)")

        do {
            if let response = try await apiService.apiPostSettingRemote(payload: payload) {
                print("✅ 除濕機 API 回應: \(response)")
            } else {
                print("❌ API 回應失敗")
            }
        } catch {
            print("❌ 發送請求時出錯: \(error)")
        }
    }
}
