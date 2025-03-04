//
//  MQTTManager.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/3.
//

import SwiftUI
import CocoaMQTT

class MQTTManager: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var loginResponse: String? // 儲存「登入」結果
    
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
    
    /// 「登入」訂閱結果的 topic
    func subscribeToAuthentication() {
        mqtt?.subscribe("to/app/authentication", qos: .qos1)
        print("📡 開始訂閱「登入」頻道：to/app/authentication")
        print("📡 訂閱登入頻道: 成功")
    }
    
    /// 「登入」發送指令
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
            mqtt?.publish("from/app/authentication", withString: jsonString, qos: .qos1, retained: false)
            print("📤 發送登入指令至 from/app/authentication")
        } else {
            print("❌ JSON 轉換失敗")
        }
    }
    
}

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("1️⃣ MQTT 連線成功: \(ack)")
        
        if ack == .accept {
            DispatchQueue.main.async {
                self.isConnected = true
            }
            subscribeToAuthentication() // 「登入」連線後自動訂閱登入結果
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
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("成功發送訊息:  \(message.string ?? "") 到 \(message.topic)")
        
        if message.topic == "to/app/authentication", let payload = message.string {
            DispatchQueue.main.async {
                self.loginResponse = payload
            }
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("成功訂閱的 topic: \(success.allKeys)")
        if !failed.isEmpty {
            print("訂閱失敗的 topic: \(failed)")
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
