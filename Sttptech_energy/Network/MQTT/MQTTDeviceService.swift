
import Foundation
import CocoaMQTT

final class MQTTDeviceService {
    private let mqtt: CocoaMQTT
    private let userToken: () -> String

    init(mqtt: CocoaMQTT, userTokenProvider: @escaping () -> String) {
        self.mqtt = mqtt
        self.userToken = userTokenProvider
    }

    func subscribeAll() {
        subscribe(to: "to/app/\(userToken())/appliances/telemetry")
        subscribe(to: "to/app/\(userToken())/appliances/capabilities")
        subscribe(to: "to/app/\(userToken())/appliances/control")
    }

    private func subscribe(to topic: String) {
        mqtt.subscribe(topic, qos: .qos1)
        print("📡 訂閱設備 Topic: \(topic)")
    }

    func publishTelemetryCommand(subscribe: Bool) {
        let payload: [String: Any] = ["token": userToken(), "subscribe": subscribe]
        publish(payload, to: "from/app/\(userToken())/appliances/telemetry")
    }

    func publishRequestCapabilities() {
        let payload: [String: Any] = ["appliance": NSNull()]
        publish(payload, to: "from/app/\(userToken())/appliances/capabilities")
    }

    func publishSetDeviceControl(model: [String: Any]) {
        let payload: [String: Any] = [
            "token": userToken(),
            "appliances": model,
            "success": true
        ]
        publish(payload, to: "from/app/\(userToken())/appliances/control")
    }

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
