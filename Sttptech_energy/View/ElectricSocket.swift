//
//  Socket.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct ElectricSocket: View {
//    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager
    @State private var isPowerOn: Bool = false // 開關控制（父控制）
    
    // MARK: - POST API
    private func postElectricSocket(mode: [String: Any]) {
        let paylod: [String: Any] = [
            "ac_outlet": mode
        ]
//        mqttManager.publishSetDeviceControl(model: paylod)
        MQTTManagerMiddle.shared.setDeviceControl(model: paylod)
        
        // 測試使用 - 解除綁定
//        mqttManager.publishUnBindSmart(deviceMac: "DE:AD:BE:EF:00:01")
        MQTTManagerMiddle.shared.unbindSmartDevice(mac: "DE:AD:BE:EF:00:01")
    }
    
    var body: some View {
        VStack () {
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) { // 設定動畫時間為 0.1 秒
                    isPowerOn.toggle()

                    let paylodModel: [String: Any] = ["cfg_power": isPowerOn]
                    postElectricSocket(mode: paylodModel)
                }
                triggerHapticFeedback() // 觸發震動
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
            Text("狀態： \(isPowerOn ? "開" : "關")")
               .padding()
            Spacer()
        }
    }
}
//
//#Preview {
//    ElectricSocket()
//}
