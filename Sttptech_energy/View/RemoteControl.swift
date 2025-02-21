//
//  RemoteControl.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct RemoteControl: View {
    @Binding var isConnected: Bool // 設備藍芽是否已連線

    @State private var selectedTab = "冷氣"
    @State private var fanSpeed: Double = 1
    @State private var temperature: Int = 21
    @State private var hasControl = true
    @State private var isPowerOn = true

    let titleWidth = 8.0;
    let titleHeight = 20.0;

    var body: some View {
        RemoteHeader(hasControl: $hasControl)
        
        if (hasControl) {
            /// 控制
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    // tag
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                    Text("控制")
                }
                RemoteControlTag(selectedTab: $selectedTab, isPowerOn: $isPowerOn)
            }
            
            if (isPowerOn) {
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
                    Image("open-power")
                    Text("請先開啟電源")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        } else {
            /// 請開始電源
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
}

#Preview {
    RemoteControl(isConnected: .constant(false))
}
