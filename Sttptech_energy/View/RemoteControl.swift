//
//  RemoteControl.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct RemoteControl: View {
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    @Binding var isConnected: Bool       // [父層控制] 設備藍芽是否已連線
    
    @AppStorage("editRemoteName") private var editRemoteName: String = ""   // ✅ 自定義設備名稱 記住連線狀態
    @AppStorage("hasControl") private var hasControl: Bool  = false         // ✅ 自定義遙控器開關 記住連線狀態
    
    @State private var isPowerOn: Bool = false               // ✅ 設備控制， 默認：關閉
    @State private var isRemoteType: String = ""             // 設備名稱， 默認：空
    @State private var isRemoteConnected: Bool = false       // 自定義遙控器 是否開始設定
    @State private var isShowingNewDeviceView: Bool = false  // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab: String = "冷氣"           // 設備控制選項，默認冷氣
    @State private var fanSpeed: Double = 1                  // 風速
    @State private var temperature: Int = 25                 // 溫度
    
    
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    //    @State private var showPopup: Bool = false
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    var body: some View {
        ZStack {
            VStack {
                if (isConnected) {
                    // ✅ 設備連結完成
                    VStack(alignment: .leading, spacing: 20) {
                        // 自定義遙控器名稱
                        RemoteHeader(hasControl: $hasControl, editRemoteName: $editRemoteName, isRemoteConnected: $isRemoteConnected)
                        
                        /// ✅ 設備已連線
                        if (hasControl) {
                            /// 控制
                            VStack(alignment: .leading, spacing: 9) {
                                HStack {
                                    // tag
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                    Text("控制")
                                }
                                RemoteControlTag(selectedTab: $selectedTab, isPowerOn: $isPowerOn)  { key in
                                    triggerAPI(for: key)  // ✅ 傳入 `triggerAPI`
                                }
                            }
                            
                            // 電源開啟狀態
                            if (isPowerOn) {
                                /// 風速
                                VStack(alignment: .leading, spacing: 9) {
                                    HStack {
                                        // tag
                                        RoundedRectangle(cornerRadius: 4)
                                            .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                        Text("風速")
                                    }
                                    FanSpeedSlider(fanSpeed: $fanSpeed) { /// 風速控制
                                        triggerAPI (for: "fan_level_rw")
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
                                    GradientProgress(currentTemperature: $temperature) { /// 溫度控制視圖
                                        triggerAPI (for: "temperature_cfg_rw")
                                    }
                                }
                            } else {
                                /// 請開始電源（電源未開啟）
                                VStack {
                                    Spacer()
                                    Image("open-power")
                                    Text("請先開啟電源")
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            
                        } else {
                            /// 請先新增遙控器
                            VStack {
                                Spacer()
                                Image("open-power-hint")
                                Text("請先新增遙控器")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .fullScreenCover(isPresented: $isRemoteConnected) {
                        // 遙控器 自定義 (只有 遙控器 才有此功能)
                        AddCustomRemoteListView(isRemoteConnected: $isRemoteConnected, isRemoteType: $isRemoteType, editRemoteName: $editRemoteName)
                            .transition(.move(edge: .trailing))  // 讓畫面從右進來
                            .background(Color.white.opacity(1))
                            .foregroundColor(Color.heavy_gray)
                        
                    }
                } else {
                    /// ✅ 設備已斷線
                    AddDeviceView(isShowingNewDeviceView: $isShowingNewDeviceView, selectedTab: $selectedTab, isConnected: $isConnected)
                }
            }
            // 👉 這裡放自訂彈窗，只在 showPopup == true 時顯示
            // if appStore.showPopup {
            //     CustomPopupView(isPresented: $appStore.showPopup, title: $appStore.title, message: $appStore.message)
            //         .transition(.opacity) // 淡入淡出效果
            //         .zIndex(1) // 確保彈窗在最上層
            // }
        }
        .animation(.easeInOut, value: appStore.showPopup)
        // 🔥 監聽 isPowerOn 的變化
        .onChange(of: isPowerOn) {  prevVal, newVal in
            print("isPowerOn -> \(newVal)")
            if newVal && !appStore.isAIControl {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    appStore.title = "是否執行以下AI決策?"
                    appStore.message = "冷氣: 27度 \n 除濕機: 開啟55%濕度 \n 電風扇: 開啟"
                    appStore.showPopup = true // 延遲3秒後開啟提示窗
                }
            }
        }
        //        .onChange(of: isPowerOn) { _, _ in triggerAPI(for:  "power_rw") }
        //        .onChange(of: selectedTab) { _, _ in triggerAPI(for: "op_mode_rw") }
        //        .onChange(of: fanSpeed) { _, _ in triggerAPI(for: "fan_level_rw") }
        //        .onChange(of: temperature) { _, _ in triggerAPI(for: "temperature_cfg_rw") }
    }
    
    // 🔥 提取 API 呼叫邏輯
    func triggerAPI(for key: String) {
        Task {
            await sendRemoteControlSettings(for: key)
        }
    }
}

extension RemoteControl {
    func changeModeNumber(modeName: String) -> String {
        switch modeName {
        case "冷氣":
            return "0"
        case "暖氣":
            return "1"
        case "除濕":
            return "2"
        case "自動":
            return "3"
        case "送風":
            return "4"
        default:
            return "99"
        }
    }
    
    func sendRemoteControlSettings(for key: String) async {
        guard isConnected else {
            print("⚠️ 設備未連線，無法送出設定")
            return
        }
        
        var payload: [String: Any] = [:]
        
        switch key {
        case "power_rw":
            payload = ["ac": ["power_rw": "3"]] // 固定值
        case "op_mode_rw":
            payload = ["ac": ["op_mode_rw": changeModeNumber(modeName: selectedTab)]] // 設備模式
        case "temperature_cfg_rw":
            payload = ["ac": ["temperature_cfg_rw": "\(temperature)"]] // 溫度
        case "fan_level_rw":
            payload = ["ac": ["fan_level_rw": "\(Int(fanSpeed))"]] // 風速
        default:
            return
        }
        
        print("PAYLOAD- RMC:\(payload)")
        
        do {
            if let response = try await apiService.apiPostSettingRemote(payload: payload) {
                closeAIControllerFeedback(appStore: appStore) // 關閉AI決策
                print("✅ 遙控器 API 回應: \(response)")
            } else {
                print("❌ API 回應失敗")
            }
        } catch {
            print("❌ 發送請求時出錯: \(error)")
        }
    }
}

//#Preview {
//    RemoteControl(isConnected: .constant(false))
//}
