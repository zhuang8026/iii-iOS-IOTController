//
//  BottomNavigationBar.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/17.
//

import SwiftUI

/// 底部導航欄
struct NavigationBar: View {
    @Binding var selectedTab: String // 標題名稱

    var body: some View {
        HStack(spacing: 0) { // 確保選項完全貼合，間距為 0
            ForEach(["溫濕度", "冷氣", "除濕機", "遙控器", "插座"], id: \.self) { tab in
                VStack {
                    Image(systemName: getTabIcon(for: tab))
                        .font(.system(size: 24))
                        .frame(width: 30, height: 30, alignment: .center)
                    Text(tab)
                        .font(.caption)
                }
                .foregroundColor(tab == selectedTab ? .g_blue : Color.gray)
                .frame(maxWidth: .infinity, maxHeight: 80) // 確保每個 VStack 寬度相等
                .background(tab == selectedTab ? Color.white : Color(hex: "#F2F2F2"))
                .onTapGesture {
                    selectedTab = tab // 更新 selectedTab
                }
            }
        }
        .frame(maxWidth: .infinity) // 確保 HStack 撐滿父容器
//        .background(Color(hex: "#F2F2F2"))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: -2)
    }
    
    private func getTabIcon(for tab: String) -> String {
        switch tab {
            case "溫濕度": return "thermometer"
            case "冷氣": return "snowflake"
            case "除濕機": return "drop.degreesign.slash"
            case "遙控器": return "appletvremote.gen1"
            case "插座": return "poweroutlet.type.b"
            default: return "questionmark"
        }
    }
}
