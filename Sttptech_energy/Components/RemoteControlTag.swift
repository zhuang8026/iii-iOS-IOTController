//
//  RemoteControlTag.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/19.
//

import SwiftUI

struct RemoteControlTag: View {
    @Binding var selectedTab: String // 標題名稱
    @Binding var isPowerOn: Bool // 開關控制（父控制）
    var triggerAPI: (String) -> Void  // ✅ 傳入觸發 API 的方法

    var body: some View {
        HStack () {
            Button(action: {
                isPowerOn.toggle()
                triggerHapticFeedback() // 觸發震動
                triggerAPI("power_rw") // 觸發 POST API -> power_rw
            }) {
                Image(systemName: "power")
                    .font(.largeTitle)
                    .foregroundColor(isPowerOn ? Color.white : Color.heavy_gray)
                    .padding()
//                    .shadow(radius: 3)
            }
            .frame(width: 80, height: 80)
            .background(isPowerOn ? Color.g_green : Color.light_gray)
            .cornerRadius(10)

            HStack(spacing: 0) { // 確保選項完全貼合，間距為 0
                ForEach(["冷氣", "暖氣", "除濕", "送風"], id: \.self) { tab in
                    VStack {
                        Image(systemName: getTabIcon(for: tab))
                            .font(.system(size: 24))
                            .frame(width: 30, height: 30, alignment: .center)
                        Text(tab)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(tab == selectedTab ? .g_blue : Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: 80) // 確保每個 VStack 寬度相等
                    .background(tab == selectedTab ? Color.white : Color.light_gray)
                    .onTapGesture {
                        selectedTab = tab // 更新 selectedTab
                        triggerHapticFeedback() // 觸發震動
                        triggerAPI("op_mode_rw") // 觸發 POST API -> op_mode_rw
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
            case "冷氣": return "snowflake"
            case "暖氣": return "sun.max"
            case "除濕": return "drop"
            case "送風": return "wind"
            default: return "questionmark"
        }
    }
}

