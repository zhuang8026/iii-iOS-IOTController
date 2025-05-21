
import Foundation
import CocoaMQTT

// MARK: - 取得家電所有資料、設備參數讀寫能力、發送與設定設備
final class MQTTDeviceService {
    private let mqtt: CocoaMQTT
    private let userToken: () -> String

    init(mqtt: CocoaMQTT, userTokenProvider: @escaping () -> String) {
        self.mqtt = mqtt
        self.userToken = userTokenProvider
    }

    func subscribeAll() {
        subscribe(to: "to/app/\(userToken())/appliances/telemetry")    // 訂閱: 取得家電所有資料
        subscribe(to: "to/app/\(userToken())/appliances/capabilities") // 訂閱: 設備參數讀寫能力
        subscribe(to: "to/app/\(userToken())/appliances/control")      // 訂閱: 發送與設定設備
    }

    private func subscribe(to topic: String) {
        mqtt.subscribe(topic, qos: .qos1)
        print("📡 訂閱設備 Topic: \(topic)")
    }
    
    // 發送 (publish)【開始/停止訂閱家電參數讀寫紀錄】指令
    func publishTelemetryCommand(subscribe: Bool) {
        let payload: [String: Any] = ["token": userToken(), "subscribe": subscribe]
        publish(payload, to: "from/app/\(userToken())/appliances/telemetry")
    }
    
    // 發送 (publish)【查詢家電能力】指令
    func publishRequestCapabilities() {
        let payload: [String: Any] = ["appliance": NSNull()]
        publish(payload, to: "from/app/\(userToken())/appliances/capabilities")
    }
    
    // 發送 (publish) 家電控制指令
    func publishSetDeviceControl(model: [String: Any]) {
        let payload: [String: Any] = [
            "token": userToken(),
            "appliances": model,
            "success": true
        ]
        publish(payload, to: "from/app/\(userToken())/appliances/control")
    }
    
    // 發送 (publish) 紀錄綁定時間指令
    func publishSetRecord(appBind: String) {
        let payload: [String: Any] = [
            "app_bind": "\(appBind)" // air_conditioner, dehumidifier
        ]
        publish(payload, to: "from/app/\(userToken())/userdata")
    }

    // 發送 (publish)
    private func publish(_ payload: [String: Any], to topic: String) {
        guard mqtt.connState == .connected else {
            print("❌ MQTT 尚未連線，無法發送 \(topic)")
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ JSON 轉換失敗")
            return
        }

        mqtt.publish(topic, withString: jsonString, qos: .qos1, retained: false)
        print("📤 發送至 \(topic): \(jsonString)")
    }
}
