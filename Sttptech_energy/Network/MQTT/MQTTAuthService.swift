import Foundation
import CocoaMQTT

// MARK: - 用戶
final class MQTTAuthService {
    private let mqtt: CocoaMQTT
    private let appID: String
    
    init(mqtt: CocoaMQTT, appID: String) {
        self.mqtt = mqtt
        self.appID = appID
    }
    
    func subscribe() {
        let topic = "to/app/\(appID)/authentication"
        mqtt.subscribe(topic, qos: .qos1)
        print("📡 訂閱登入頻道: \(topic)")
    }
    
    func publishLogin(username: String, password: String) {
        guard mqtt.connState == .connected else {
            print("❌ MQTT 尚未連線，無法發送登入")
            return
        }
        
        let payload: [String: String] = [
            "username": username,
            "password": password,
            "client_id": appID,
            "client_secret": appID
        ]
        
        publishJSON(payload, to: "from/app/\(appID)/authentication")
    }
    
    private func publishJSON(_ payload: [String: Any], to topic: String) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8) else {
            print("❌ 登入 payload 轉換 JSON 失敗")
            return
        }
        
        mqtt.publish(topic, withString: json, qos: .qos1, retained: false)
        print("📤 發送登入指令至 \(topic): \(json)")
    }
}
