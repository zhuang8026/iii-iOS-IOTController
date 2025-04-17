
//
//  MQTTManagerTools.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/4/17.
//
import SwiftUI
import CocoaMQTT

class MQTTManagerTool: NSObject, ObservableObject {
    static let shared = MQTTManagerTool()

    @Published var isConnected = false
    @Published var loginResponse: String?
    @Published var availables: [String] = []
    @Published var appliances: [String: [String: ApplianceData]] = [:]

    var mqtt: CocoaMQTT?

    func connectMQTT() {
        let clientID = "iOS_Client_\(UUID().uuidString.prefix(6))"
        mqtt = CocoaMQTT(clientID: clientID, host: "openenergyhub.energy-active.org.tw", port: 1884)
        mqtt?.username = "app"
        mqtt?.password = "app:ppa"
        mqtt?.delegate = self

        print("⏰ 準備連線 MQTT")
        if let isConnected = mqtt?.connect() {
            print("🚀 MQTT 連線狀態: \(isConnected ? "成功" : "失敗")")
        }
    }

    func disconnectMQTT() {
        mqtt?.disconnect()
        print("🔴 MQTT 已斷線")
    }
}

extension MQTTManagerTool: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("✅ MQTT 連線成功: \(ack)")
        if ack == .accept {
            DispatchQueue.main.async { self.isConnected = true }
            MQTTCommandService.shared.subscribeToSmart()
            MQTTCommandService.shared.subscribeToTelemetry()
            MQTTCommandService.shared.subscribeToControl()
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        guard let payload = message.string,
              let data = payload.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        print("message.topic:\(message.topic)")
        DispatchQueue.main.async {
            if message.topic.contains("/authentication") {
                self.loginResponse = String(describing: json["success"] as? Bool ?? false)
                if let token = json["application_access_token"] as? String {
                    UserDefaults.standard.set(token, forKey: "MQTTAccessToken")
                }
            } else if message.topic.contains("/appliances/telemetry") {
                if let availables = json["availables"] as? [String] {
                    
                    print("availables:\(availables)")
                    self.availables = availables
                }

                if let appliancesData = json["appliances"] as? [String: [String: [String: String]]] {
                    var parsed: [String: [String: ApplianceData]] = [:]
                    for (device, parameters) in appliancesData {
                        var deviceData: [String: ApplianceData] = [:]
                        for (param, values) in parameters {
                            if let value = values["value"], let updated = values["updated"] {
                                deviceData[param] = ApplianceData(value: value, updated: updated)
                            }
                        }
                        parsed[device] = deviceData
                    }
                    self.appliances = parsed
                }
            }
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("⚠️ 狀態變更: \(state)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📤 已發送: \(message.string ?? "")")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("📬 Publish ACK: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("✅ 訂閱成功: \(success.allKeys)")
        if !failed.isEmpty { print("❌ 訂閱失敗: \(failed)") }
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("🧹 取消訂閱: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("🔁 發送 Ping")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("🏓 收到 Pong")
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("❌ MQTT 斷線: \(err?.localizedDescription ?? "未知錯誤")")
        DispatchQueue.main.async { self.isConnected = false }
    }
}
