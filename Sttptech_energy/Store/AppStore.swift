//
//  Store.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/27.
//

import SwiftUI

// ✅ 1. 創建全域狀態 Store
class AppStore: ObservableObject {
    @Published var showPopup: Bool = false // 提示窗顯示 開關
    @Published var isAIControl: Bool = false // AI決策顯示 開關
    @Published var title: String = "執行AI決策"
    @Published var message: String  = "冷氣: 27度 \n 除濕機: 開啟55%濕度 \n 電風扇: 開啟"
    @Published var notificationsResult: String  = "AI決策正在執行中"
//    
//    @Published var loginResponse: String?
//    @Published var availables: [String] = []
//    @Published var appliances: [String: [String: ApplianceData]] = [:]
//    
//    func bindSmart(deviceMac: String) {
//        MQTTCommandService.shared.publishBindSmart(deviceMac: deviceMac)
//    }
//    
//    func unbindSmart(deviceMac: String) {
//        MQTTCommandService.shared.publishUnbindSmart(deviceMac: deviceMac)
//    }
//    
//    func setDeviceControl(model: [String: Any]) {
//        MQTTCommandService.shared.publishSetDeviceControl(model: model)
//    }
//    
//    func fetchTelemetry(enable: Bool) {
//        MQTTCommandService.shared.publishTelemetryCommand(subscribe: enable)
//    }
//    
//    func login(username: String, password: String) {
//        MQTTCommandService.shared.publishLogin(username: username, password: password)
//    }
    
}
