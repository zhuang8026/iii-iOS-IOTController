//
//  Temperature.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct Temperature: View {
    @State private var isShowingNewDeviceView = false
    @State private var selectedTab = "溫濕度"
//    @State private var isDeviceConnected = false
    @Binding var isConnected: Bool // 設備藍芽是否已連線
//    @AppStorage("isConnected") private var isConnected = false // ✅ 記住連線狀態
    
    var body: some View {
       if (isConnected) {
//           Button("模擬設備連線") {
//               isConnected = false // ✅ 設備連上後會自動影響 `ContentView` 的 tabStatusList
//          }
           /// ✅ 設備已連線
           VStack(spacing: 9) {
               Spacer()
               CircularProgressBar(progress: 0.75)
               Spacer()
               EnvironmentalCardView()
           }
       } else {
           /// ✅ 設備已斷線
           VStack(spacing: 9) {
               Spacer()

               Button(action: {
                   withAnimation(.easeInOut(duration: 0.3)) {
                       isShowingNewDeviceView = true  // 觸發畫面切換
                       triggerHapticFeedback(model: .heavy) // 觸發震動
                   }
               }) {
                   ZStack {
                       Circle()
                           .fill(
                               LinearGradient(
                                   gradient: Gradient(stops: [
                                       Gradient.Stop(color: Color(red: 93.0 / 255.0, green: 194.0 / 255.0, blue: 184.0 / 255.0), location: 0.0),
                                       Gradient.Stop(color: Color(red: 18.0 / 255.0, green: 132.0 / 255.0, blue: 147.0 / 255.0), location: 1.0)
                                   ]),
                                   startPoint: .top,
                                   endPoint: .bottom
                               )
                           )
                           .frame(width: 80, height: 80) // 設定按鈕大小
                           .shadow(radius: 4) // 添加陰影讓 UI 更有層次感

                       Image(systemName: "plus")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 30, height: 30) // 調整「+」圖示大小
                           .foregroundColor(.white) // 設定圖示顏色
                   }
               }
               .buttonStyle(PlainButtonStyle()) // 移除按鈕的默認樣式

               Text("新增裝置")
                   .font(.system(size: 14)) // 调整图标大小
                   .foregroundColor(Color.g_blue)
               Spacer()
           }
           .fullScreenCover(isPresented: $isShowingNewDeviceView) {
           BluetoothView(isPresented: $isShowingNewDeviceView, selectedTab: $selectedTab, isConnected: $isConnected)
               .transition(.move(edge: .trailing))  // 讓畫面從右進來
               .background(Color(hex: "#DEEBEA").opacity(1))
           }
       }
    }
}

//#Preview {
//    Temperature()
//}
