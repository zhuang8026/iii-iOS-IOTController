//
//  BottomNavigationBar.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/17.
//
import SwiftUI

/// 底部導航欄
struct NavigationBar: View {
    @Binding var selectedTab: String // 目前選中的標籤
//    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager
    
    // 家電類型對應的名稱
    private let deviceMapping: [String: String] = [
        "sensor": "溫濕度",
        "air_conditioner": "空調",
        "dehumidifier": "除濕機",
        "remote": "遙控器",
        "ac_outlet": "插座"
    ]
    
    var body: some View {
        HStack(spacing: 0) { // 水平排列按鈕
            ForEach(getAvailableTabs(), id: \.self) { tab in
                VStack {
                    Image(systemName: getTabIcon(for: tab))
                        .font(.system(size: 24))
                        .frame(width: 30, height: 30, alignment: .center)
                    Text(tab)
                        .font(.caption)
                }
                .foregroundColor(tab == selectedTab ? .blue : .gray)
                .frame(maxWidth: .infinity, maxHeight: 80) // 確保每個 VStack 均等寬度
                .background(tab == selectedTab ? Color.white : Color(hex: "#F2F2F2"))
                .onTapGesture {
                    selectedTab = tab // 更新 selectedTab
                }
            }
        }
        .frame(maxWidth: .infinity) // 確保 HStack 撐滿父容器
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: -2)
        .onAppear {
            updateSelectedTab() // 頁面出現時執行
        }
        .onChange(of: MQTTManagerMiddle.shared.availables) { _, _ in
            updateSelectedTab() // 當 MQTT 數據更新時執行
        }
    }
    
    /// 取得可用的標籤名稱（從 MQTTManager 解析）
    private func getAvailableTabs() -> [String] {
//        mqttManager.availables.compactMap { deviceMapping[$0] }
        return ["溫濕度", "空調", "除濕機", "遙控器", "插座"]
    }
    /// 當 availables 更新時，確保 selectedTab 有正確的值
    private func updateSelectedTab() {
        if selectedTab.isEmpty, let firstAvailable = getAvailableTabs().first {
            selectedTab = firstAvailable
        }
    }
    /// 取得對應的 SF Symbols 圖示
    private func getTabIcon(for tab: String) -> String {
        switch tab {
        case "溫濕度": return "thermometer"
        case "空調": return "air.conditioner.horizontal"
        case "除濕機": return "drop.degreesign.slash"
        case "遙控器": return "appletvremote.gen1"
        case "插座": return "poweroutlet.type.b"
        default: return "questionmark"
        }
    }
}
