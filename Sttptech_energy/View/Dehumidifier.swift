//
//  Dehumidifier.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Dehumidifier: View {
    @State private var isPowerOn = true
    @State private var fanSpeed: Double = 2
    
    // 選項結果
    @State private var selectedHumidity: Int = 50
    @State private var selectedTimer: Int = 2
    @State private var selectedWaterLevel: String = "正常"
    @State private var selectedMode: String = "自動除濕"
    
    // 選項列表
    let humidityOptions = Array(stride(from: 20, through: 60, by: 10)) // 40% - 80%
    let timerOptions = Array(1...6) // 1 - 12 小時
    let waterLevelOptions = ["正常", "過低", "滿水"]
    let modeOptions = ["自動除濕", "連續除濕"]
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    var body: some View {
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
                        .buttonStyle(NoAnimationButtonStyle()) // 使用自訂樣式，完全禁用動畫
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
    }
}

#Preview {
    Dehumidifier()
}
