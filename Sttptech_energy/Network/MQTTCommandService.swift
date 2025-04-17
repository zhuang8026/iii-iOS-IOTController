//
//  MQTTCommandService.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/4/17.
//

import Foundation
import CocoaMQTT

final class MQTTCommandService {
    
    static let shared = MQTTCommandService()
    
    private init() {}
    
    private let appID = "1d51e92d-e623-41dd-b367-d955a0d44d66"
    private var userToken: String {
        return UserDefaults.standard.string(forKey: "MQTTAccessToken") ?? "bhWHWKziOCW5r1NqAcBpTTyqEIxng1AMvw0MtYrfDTpW94ikFy6o3Yl9hGWuzNhqAe3gQaSBrRYiml1SqeNv62DiDgf1wRXTeqAsSIRxzfz9OzxF8OYLMWnFtxHH2fYY5Ye4yCxZ3KigSNpeolWYyDvuys9p2S32an941qp1twFDVaDCMJFvPooBpyVJxyIWOgKyXPhkiWbVLq5umMHKPrLiPXbI0mvFZ7y3mHPVKzf2BM6EZYfF7wtigchSgZtQBXYSBfm9M6Xk1P4xvJ3LgvH0KLAwm84KLTyaVJJnkZgKsXDtKfOyeiWpVp0ncGvTsQT91rqm9bkUg9aHWagMcBLJOZTa9E2X3F4C7w7v1m3kY4RQxTgyaXagtRz1WOWWvHEjgiTMuLecX6ZmjNgb9pj1nPA"
    }

    private var mqtt: CocoaMQTT? {
        return MQTTManager.shared.mqtt
    }

    private func publish(topic: String, payload: [String: Any]) {
        guard let mqtt = mqtt else {
            print("❌ MQTT 尚未建立")
            return
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ JSON 格式錯誤")
            return
        }
        mqtt.publish(topic, withString: jsonString, qos: .qos1, retained: false)
        print("📤 發送至 \(topic): \(jsonString)")
    }

    // MARK: - 登入
    func subscribeToAuthentication() {
        let topic = "to/app/\(appID)/authentication"
        mqtt?.subscribe(topic, qos: .qos1)
    }

    func publishLogin(username: String, password: String) {
        let topic = "from/app/\(appID)/authentication"
        let payload: [String: String] = [
            "username": username,
            "password": password,
            "client_id": appID,
            "client_secret": appID
        ]
        publish(topic: topic, payload: payload)
    }

    // MARK: - 智慧環控
    func subscribeToSmart() {
        let topic = "to/app/\(userToken)/appliance/edge"
        mqtt?.subscribe(topic, qos: .qos1)
    }

    func publishBindSmart(deviceMac: String) {
        let topic = "from/app/\(userToken)/appliance/edge"
        publish(topic: topic, payload: ["bind": deviceMac])
    }

    func publishUnbindSmart(deviceMac: String) {
        let topic = "from/app/\(userToken)/appliance/edge"
        publish(topic: topic, payload: ["unbind": deviceMac])
    }

    // MARK: - 家電資料
    func subscribeToTelemetry() {
        let topic = "to/app/\(userToken)/appliances/telemetry"
        mqtt?.subscribe(topic, qos: .qos1)
    }

    func publishTelemetryCommand(subscribe: Bool) {
        let topic = "from/app/\(userToken)/appliances/telemetry"
        publish(topic: topic, payload: ["token": userToken, "subscribe": subscribe])
    }

    // MARK: - 設備控制
    func subscribeToControl() {
        let topic = "to/app/\(userToken)/appliances/control"
        mqtt?.subscribe(topic, qos: .qos1)
    }

    func publishSetDeviceControl(model: [String: Any]) {
        let topic = "from/app/\(userToken)/appliances/control"
        let payload: [String: Any] = [
            "token": userToken,
            "appliances": model,
            "success": true
        ]
        publish(topic: topic, payload: payload)
    }
}
