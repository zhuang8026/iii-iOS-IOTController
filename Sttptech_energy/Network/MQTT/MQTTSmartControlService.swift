import Foundation
import CocoaMQTT

final class MQTTSmartControlService {
    private let mqtt: CocoaMQTT
    private let userToken: () -> String

    init(mqtt: CocoaMQTT, userTokenProvider: @escaping () -> String) {
        self.mqtt = mqtt
        self.userToken = userTokenProvider
    }

    func subscribe() {
        let topic = "to/app/\(userToken())/appliance/edge"
        mqtt.subscribe(topic, qos: .qos1)
        print("📡 訂閱 Smart 控制 topic: \(topic)")
    }

    func publishBind(deviceMac: String) {
        let payload: [String: String] = ["bind": deviceMac]
        publish(payload)
        print("Smart綁定: \(payload)")
    }

    func publishUnbind(deviceMac: String) {
        let payload: [String: String] = ["unbind": deviceMac]
        publish(payload)
        print("Smart解除綁定: \(payload)")
    }

    private func publish(_ payload: [String: String]) {
        guard mqtt.connState == .connected else {
            print("❌ MQTT 未連線，無法發送 Smart 控制")
            return
        }

        guard let json = try? JSONSerialization.data(withJSONObject: payload),
              let jsonStr = String(data: json, encoding: .utf8) else {
            print("❌ JSON 轉換失敗")
            return
        }

        let topic = "from/app/\(userToken())/appliance/edge"
        mqtt.publish(topic, withString: jsonStr, qos: .qos1, retained: false)
        print("📤 發送 Smart 控制 payload 至 \(topic): \(jsonStr)")
    }
}

