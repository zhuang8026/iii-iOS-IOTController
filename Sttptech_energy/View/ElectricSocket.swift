//
//  Socket.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct ElectricSocket: View {
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    
    @State private var isPowerOn: Bool = false // 開關控制（父控制）
    @State private var sendSocket: ApiResponse?
    
    var body: some View {
        VStack () {
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) { // 設定動畫時間為 0.1 秒
                    isPowerOn.toggle()
                }
                triggerHapticFeedback() // 觸發震動
                
                // ✅ 發送 API 請求
                Task {
                    let payload: [String: Any] = [
                        "socket": [
                            "power_w": isPowerOn ? "1" : "0"
                        ]
                    ]
                    print("✅ POST Socket payload -> \(payload)")
                    sendSocket = try await apiService.apiPostSettingSocket(payload: payload)
                    print("✅ POST Socket API -> \(sendSocket)")
                    closeAIControllerFeedback(appStore: appStore) // 關閉AI決策
                }
            }) {
                Image(systemName: "power")
                    .font(.system(size: 80.0))
                    .foregroundColor(isPowerOn ? Color.white : Color.heavy_gray)
                    .padding()
            }
            .frame(width: 150, height: 150)
            .background(isPowerOn ? Color.g_green : Color.light_gray)
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: -4, y: 4) // 陰影效果
            .overlay(
                RoundedRectangle(cornerRadius: 75)
                    .stroke(Color.white, lineWidth: 6) // 添加 3px 白色邊框
            )
            .cornerRadius(75)
            .onAppear {
                print("🟢 ElectricSocket 进入画面，当前 isAIControl = \(appStore.isAIControl)")
                
                if appStore.isAIControl {
                    isPowerOn = true
                    print("🔄 进入画面时发现 AI 控制已开启，isPowerOn 设为 true")
                }
            }
            
            Spacer()
        }
    }
}

//
//#Preview {
//    ElectricSocket()
//}
