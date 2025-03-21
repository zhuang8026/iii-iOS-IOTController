//
//  RemoteControlTag.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/19.
//

import SwiftUI

struct RemoteControlTag: View {
    @Binding var selectedTab: String // 標題名稱
//    @Binding var isPowerOn: Bool // 開關控制（父控制）
    
    @State private var modes = ["cool", "heat", "dry", "fan", "auto"]
    
    /// **模式轉換函式**
    private func verifyMode(_ mode: String) -> String {
        switch mode {
        case "cool": return "冷氣"
        case "heat": return "暖風"
        case "dry": return "除濕"
        case "fan": return "送風"
        case "auto": return "自動"
        default: return "其他"
        }
    }
    
    var body: some View {
        HStack () {
            HStack(spacing: 0) { // 確保選項完全貼合，間距為 0
                ForEach(modes, id: \.self) { tab in
                    VStack {
                        if(tab == selectedTab) {
                            Image(systemName: getTabIcon(for: tab))
                                .font(.system(size: 24))
                                .frame(width: 30, height: 30, alignment: .center)
                                .symbolEffect(.bounce.down.byLayer, options: .nonRepeating)
                        } else {
                            Image(systemName: getTabIcon(for: tab))
                                .font(.system(size: 24))
                                .frame(width: 30, height: 30, alignment: .center)
                                .opacity(0.7)
                        }
                        
                        Text(verifyMode(tab))
                            .font(.system(size: 14))
                    }
                    .foregroundColor(tab == selectedTab ? .g_blue : Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: 80) // 確保每個 VStack 寬度相等
                    .background(tab == selectedTab ? Color.white : Color.light_gray.opacity(0.7))
                    .shadow( color: tab == selectedTab ? Color.black.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 0) // ✅ 添加陰影
                    .onTapGesture {
                        selectedTab = tab // 更新 selectedTab
                        triggerHapticFeedback() // 觸發震動
                    }
                }
            }
            .frame(maxWidth: .infinity) // 確保 HStack 撐滿父容器
            //        .background(Color(hex: "#F2F2F2"))
            .cornerRadius(10)
            //            .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: -2)
        }
    }
    
    private func getTabIcon(for tab: String) -> String {
        switch tab {
        case "cool": return "snowflake"
        case "heat": return "sun.max"
        case "dry": return "drop"
        case "fan": return "wind"
        case "auto": return "autostartstop"
        default: return "questionmark"
        }
    }
}

