//
//  AirConditioner.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/20.
//

import SwiftUI

struct AirConditioner: View {
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    @State private var roomData: RoomData?
    
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    @State private var isPowerOn = true
    @State private var selectedMode = 0
    @State private var fanSpeed: Double = 1.0
    @State private var temperature: Int = 16
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    /// HStack 控制水平排列，VStack 控制垂直排列
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                PowerToggle(isPowerOn: $isPowerOn)
                
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
                        ModeSelector(selectedMode: $selectedMode)
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
                Task {
                    roomData = await apiService.apiGetDehumidifierInfo() // ✅ 自動載入設備資料
//                    print("roomData:\(roomData?.ac)")
                    guard let ac = roomData?.ac else { return }
                    //
                    isPowerOn = ac.power_rw == "1"
                    selectedMode = Int(ac.op_mode_rw) ?? 0
                    temperature = Int(ac.temperature_cfg_rw) ?? 16
                    fanSpeed = Double(ac.fan_level_rw) ?? 1.0
                }
            }
        }
    }
}

#Preview {
    AirConditioner()
}
