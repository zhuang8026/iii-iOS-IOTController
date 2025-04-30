import Foundation
import CocoaMQTT

final class MQTTConnectionService {
    private let mqtt: CocoaMQTT

    init(clientID: String, host: String, port: UInt16) {
        self.mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        self.mqtt.username = "app"
        self.mqtt.password = "app:ppa"
    }

    func setDelegate(_ delegate: CocoaMQTTDelegate) {
        mqtt.delegate = delegate
    }

    func connect() {
        print("🔌 嘗試建立 MQTT 連線")
        _ = mqtt.connect()
    }

    func disconnect() {
        mqtt.disconnect()
        print("🔌 MQTT 已中斷")
    }

    var instance: CocoaMQTT {
        return mqtt
    }

    var isConnected: Bool {
        return mqtt.connState == .connected
    }
}
