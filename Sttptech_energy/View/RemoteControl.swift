//
//  RemoteControl.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct RemoteControl: View {
    @Binding var isConnected: Bool       // [父層控制] 設備藍芽是否已連線

    @AppStorage("editRemoteName") private var editRemoteName: String = ""   // ✅ 自定義設備名稱 記住連線狀態
    @AppStorage("hasControl") private var hasControl: Bool  = false         // ✅ 自定義遙控器開關 記住連線狀態
    @AppStorage("isPowerOn")  private var isPowerOn: Bool = true           // ✅ 設備控制， 默認：關閉

    @State private var isRemoteType = "" // 設備名稱， 默認：空
    @State private var isRemoteConnected: Bool = false       // 自定義遙控器 是否開始設定
    @State private var isShowingNewDeviceView: Bool = false  // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab: String = "冷氣"           // 設備控制選項，默認冷氣
    @State private var fanSpeed: String = "max"
    @State private var temperature: Int = 21

    
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
                                    Text("模式")
                                }
                                RemoteControlTag(selectedTab: $selectedTab, isPowerOn: $isPowerOn)
                            }
                            
                            // 電源開啟狀態
                            if (isPowerOn) {
                                /// 風量
                                VStack(alignment: .leading, spacing: 9) {
                                    HStack {
                                        // tag
                                        RoundedRectangle(cornerRadius: 4)
                                            .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                        Text("風速")
                                    }
//                                    FanSpeedSlider(fanSpeed: $fanSpeed) /// 風量控制
                                    WindSpeedView(selectedSpeed: $fanSpeed) // 風速控制
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
            // AI決策啟動 視窗
            //            .fullScreenCover(isPresented: $showPopup) {
            //                CustomPopupView(isPresented: $showPopup)
            //            }
            // 👉 這裡放自訂彈窗，只在 showPopup == true 時顯示
            if appStore.showPopup {
                CustomPopupView(isPresented: $appStore.showPopup, title: $appStore.title, message: $appStore.message)
                    .transition(.opacity) // 淡入淡出效果
                    .zIndex(1) // 確保彈窗在最上層
            }
        }
        .animation(.easeInOut, value: appStore.showPopup)
        // 🔥 監聽 isPowerOn 的變化
        .onChange(of: isPowerOn) { oldVal, newVal in
            print("isPowerOn -> \(newVal)")
            if newVal {
                appStore.showPopup = true // 開啟提示窗
            }
        }
    }
}

//#Preview {
//    RemoteControl(isConnected: .constant(false))
//}
