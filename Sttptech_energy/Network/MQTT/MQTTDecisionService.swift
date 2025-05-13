
import Foundation
import CocoaMQTT

// MARK: - 未定案 用戶是否接受 AI 執行
final class MQTTDecisionService {
    private let mqtt: CocoaMQTT
    private let userToken: () -> String
    
    init(mqtt: CocoaMQTT, userTokenProvider: @escaping () -> String) {
        self.mqtt = mqtt
        self.userToken = userTokenProvider
    }
    
    func subscribeAll() {
        subscribe(to: "to/app/\(userToken())/appliances/decision/config")
        subscribe(to: "to/app/\(userToken())/appliances/decision/notify")
    }

    func publishDecisionAccepted(_ accepted: Bool) {
        let payload: [String: Bool] = ["accepted": accepted]
        publish(payload, to: "from/app/\(userToken())/appliances/decision/config")
    }

    private func subscribe(to topic: String) {
        mqtt.subscribe(topic, qos: .qos1)
        print("📡 訂閱 AI 決策 Topic: \(topic)")
    }
    
    private func publish(_ payload: [String: Bool], to topic: String) {
        guard mqtt.connState == .connected else {
            print("❌ MQTT 尚未連線，無法發送 AI 決策")
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
