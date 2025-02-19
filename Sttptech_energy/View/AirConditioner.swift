//
//  AirConditioner.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/20.
//

import SwiftUI

struct AirConditioner: View {
    @State private var isPowerOn = true
    @State private var selectedMode = "冷氣"
    @State private var fanSpeed: Double = 2
    @State private var temperature: Int = 24
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    /// HStack 控制水平排列，VStack 控制垂直排列
    var body: some View {
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
                Image("openPowerHint")
                Text("請先啟動設備")
                    .font(.body)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

//#Preview {
//    AirConditioner()
//}
