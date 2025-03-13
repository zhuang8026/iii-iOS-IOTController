//
//  MQTTManager.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/3.
//

import SwiftUI
import CocoaMQTT

// MARK: - [對外] 核心功能
class MQTTManager: NSObject, ObservableObject {
    static let shared = MQTTManager()
    
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    // MARK: - MQTT連線狀態
    @Published var isConnected = false
    // MARK: - 登入狀態
    @Published var loginResponse: String? // 儲存「登入」結果
    // MARK: - 家電總資料
    @Published var availables: [String] = [] // 可使用的家電名稱
    @Published var appliances: [String: [String: ApplianceData]] = [:] // 安裝的家電參數狀態
    
    let AppID = "1d51e92d-e623-41dd-b367-d955a0d44d66" // 測試使用
    
    var mqtt: CocoaMQTT?
    
    func connectMQTT() {
        let clientID = "iOS_Client_\(UUID().uuidString.prefix(6))"
        mqtt = CocoaMQTT(clientID: clientID, host: "openenergyhub.energy-active.org.tw", port: 1883) // ex: host: "broker.hivemq.com", port: 1883
        mqtt?.delegate = self
        //        mqtt?.connect()
        if let isConnected = mqtt?.connect() {
            print("🚀 MQTT 連線狀態: \(isConnected ? "成功" : "失敗")")
        }
    }
    
    func disconnectMQTT() {
        mqtt?.disconnect()
        print("🔴 MQTT 已斷線")
    }
    
    // MARK: - 登入
    // 訂閱「登入」訂閱結果的 topic
    func subscribeToAuthentication() {
        mqtt?.subscribe("to/app/\(AppID)/authentication", qos: .qos1) // API
        print("📡 開始訂閱「登入」頻道：to/app/\(AppID)authentication")
        print("📡 訂閱登入頻道: 成功")
    }
    
    // 發布「登入」發送指令
    func publishLogin(username: String, password: String) {
        guard isConnected else {
            print("❌ MQTT 未連線，無法發送登入指令")
            return
        }
        
        let loginPayload: [String: String] = [
            "username": username,
            "password": password,
            "client_id": "1d51e92d-e623-41dd-b367-d955a0d44d66",
            "client_secret": "1d51e92d-e623-41dd-b367-d955a0d44d66"
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: loginPayload, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt?.publish("from/app/\(AppID)/authentication", withString: jsonString, qos: .qos1, retained: false)
            print("📤 發送登入指令至 from/app/\(AppID)authentication")
        } else {
            print("❌ JSON 轉換失敗")
        }
    }
    
    // MARK: - 溫濕度API
    // 訂閱家電資訊
    func subscribeToApplianceTelemetry() {
        let topic = "to/app/\(AppID)/appliances/telemetry" // API
        mqtt?.subscribe(topic)
        print("📡 訂閱家電資訊: \(topic)")
    }
    
    //  發布 開始 or 停止 接收家電資訊指令
    func publishApplianceTelemetryCommand(subscribe: Bool) {
        let topic = "from/app/\(AppID)/appliances/telemetry" // API
        var uerToken:String = "----------- William testing token -----------" // 測試 Token
        if let token = UserDefaults.standard.string(forKey: "MQTTAccessToken") {
            print("🔑 讀取到存儲的 Token: \(token)")
            uerToken = token
        }
        // 確保 payload 在 uerToken 更新後才建立
        let payload: [String: Any] = ["token": uerToken, "subscribe": subscribe]
        
        print("⭐ 讀取到存儲的 payload: \(payload)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt?.publish(topic, withString: jsonString)
            print("🚀 發送 \(subscribe ? "開始" : "停止") 接收家電資訊指令: \(jsonString)")
        }
    }
    
}

// MARK: - [對內] 負責 MQTT 代理方法
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("1️⃣ MQTT 連線成功: \(ack)")
        
        if ack == .accept {
            DispatchQueue.main.async {
                self.isConnected = true
            }
            subscribeToAuthentication() // 「登入」連線後自動訂閱登入結果
            subscribeToApplianceTelemetry() //「溫濕度」連線後自動訂閱登入結果
        } else {
            print("❌ MQTT 連線失敗: \(ack)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("⚠️ MQTT 狀態變更: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT 消息已發布: \(message.string ?? "")")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT 發布收到的 id 確認: \(id)")
    }
    
    // MARK: - 取得 API 回應
    // response data
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
//        print("MQTT 成功發送訊息:  \(message.string ?? "") 到 \(message.topic)")
        print("MQTT 成功發送訊息到 -> \(message.topic)")
        
        // [token] 確保是訂閱的 topic
        if message.topic == "to/app/\(AppID)/authentication", let payload = message.string {
            DispatchQueue.main.async {
                // 解析 JSON 取得 Token
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    // 取得 `success` 欄位的值
                    if let success = json["success"] as? Bool {
                        self.loginResponse =  String(success)
                    }
                    
                    // 取得 `application_access_token` 並存入 UserDefaults
                    if let token = json["application_access_token"] as? String {
                        UserDefaults.standard.set(token, forKey: "MQTTAccessToken")
                        //                        print("✅ Token 已儲存：\(token)")
                    }
                }
            }
            //            print("✅ 登入回應: \(payload)")
        }
        
        if message.topic == "to/app/\(AppID)/appliances/telemetry", let payload = message.string {
            DispatchQueue.main.async {
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    // MARK: - MenuBAR
                    // 解析 availables
                    if let availableDevices = json["availables"] as? [String] {
                        self.availables = availableDevices
                        //                        print("✅ 可用家電: \(availableDevices)")
                    }
                    
                    // MARK: - 所有電器資料
                    /// 解析 appliances
                    if let appliancesData = json["appliances"] as? [String: [String: [String: String]]] {
                        var parsedAppliances: [String: [String: ApplianceData]] = [:]
                        
                        for (device, parameters) in appliancesData {
                            var deviceData: [String: ApplianceData] = [:]
                            for (param, values) in parameters {
                                if let value = values["value"], let updated = values["updated"] {
                                    deviceData[param] = ApplianceData(value: value, updated: updated)
                                }
                            }
                            parsedAppliances[device] = deviceData
                        }
                        
                        self.appliances = parsedAppliances
//                        print("✅ 總家電參數更新: \(parsedAppliances)")
                        if let dehumidifierData = parsedAppliances["sensor"] {
                            print("✅ 溫濕度數據: \(dehumidifierData)")
                        }
                    }
                }
            }
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("🎉 成功訂閱的 topic: \(success.allKeys)")
        if !failed.isEmpty {
            print("🛑 訂閱失敗的 topic: \(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("成功取消訂閱的 topic: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("🔜 MQTT Ping 發送請求成功")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("🔙 MQTT 收到 Pong 回應")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("❌ MQTT 斷線: \(err?.localizedDescription ?? "未知錯誤")")
    }
}
