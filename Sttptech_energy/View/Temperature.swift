//
//  Temperature.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Temperature: View {
    @State private var isShowingNewDeviceView = false // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab = "溫濕度"
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    //    @AppStorage("isConnected") private var isConnected = false // ✅ 記住連線狀態
    
    var body: some View {
        if (isConnected) {
            /// ✅ 設備已連線
            VStack(spacing: 9) {
                Spacer()
                CircularProgressBar(progress: 0.75)
                Spacer()
                EnvironmentalCardView()
            }
        } else {
            /// ✅ 設備已斷線
            AddDeviceView(isShowingNewDeviceView: $isShowingNewDeviceView, selectedTab: $selectedTab, isConnected: $isConnected)
        }
    }
}

#Preview {
    Temperature(isConnected: .constant(false))
}
