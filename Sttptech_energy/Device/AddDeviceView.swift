//
//  AddDeviceView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/24.
//

import SwiftUI

struct AddDeviceView: View {
    @Binding var isShowingNewDeviceView: Bool  // 是否要開始藍芽配對介面，默認：關閉
    @Binding var selectedTab:String // 設備名稱
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    var body: some View {
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
                .background(Color.light_green.opacity(1))
            
        }
    }
}

//#Preview {
//    AddDeviceView()
//}
