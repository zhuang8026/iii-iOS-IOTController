//
//  RemoteControl.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct RemoteControl: View {
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    @State private var isRemoteType = "" // 設備名稱， 默認：空
    @State private var editRemoteName: String = "" // 自定義設備名稱
    @State private var isRemoteConnected: Bool = false // 自定義遙控器是否開始設定
    
    @State private var isShowingNewDeviceView = false // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab = "冷氣" // 設備控制選項，默認冷氣
    @State private var fanSpeed: Double = 1
    @State private var temperature: Int = 21
    @State private var hasControl = false // 自定義遙控器名稱，默認：關閉
    @State private var isPowerOn = false // 設備控制， 默認：關閉
    
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    var body: some View {
        VStack {
            if (isConnected) {
                // ✅ 設備連結完成
                VStack() {
                    // 自定義遙控器名稱
                    RemoteHeader(hasControl: $hasControl)
                    
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
                            RemoteControlTag(selectedTab: $selectedTab, isPowerOn: $isPowerOn)
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
        .task {
            await MainActor.run {
                print("初始化時 isConnected = \(isConnected)")
                if(isConnected && editRemoteName.isEmpty) {
                    isRemoteConnected = true
                }
            }
        }
        .onChange(of: isConnected) { oldValue, newValue in
            print("父層監聽: isConnected 從 \(oldValue) 變為 \(newValue)")
        }
    }
}

//#Preview {
//    RemoteControl(isConnected: .constant(false))
//}
