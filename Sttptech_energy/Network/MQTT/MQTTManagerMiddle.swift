import Foundation
import CocoaMQTT
import Combine

final class MQTTManagerMiddle: NSObject, ObservableObject {
    static let shared = MQTTManagerMiddle()
    
    // MARK: - MQTT連線狀態
    @Published var isConnected: Bool = false
    // MARK: - Smart Control 連線狀態
    @Published var isSmartBind: Bool = false
    // MARK: - AI決策 是否同意 AI控制狀態
    @Published var decisionEnabled: Bool = false
    // MARK: - 登入狀態
    @Published var loginResponse: String? // 儲存「登入」結果
    // MARK: - 導航欄資料
    @Published var availables: [String] = [] // MenuBar顯示家電控制 項目
    // MARK: - 欄位讀寫能力
    @Published var deviceCapabilities: [String: [String: [String]]] = [:]
    // MARK: - MQTT 是否已取得資料（loading畫面）
    @Published var serverLoading: Bool = true
    // MARK: - 家電總資料
    @Published var appliances: [String: [String: ApplianceData]] = [:] // 安裝的家電參數狀態
    
    private let appID = "1d51e92d-e623-41dd-b367-d955a0d44d66"
    
    // MARK: - MQTT
    private var connectionService: MQTTConnectionService!
    
    // MARK: - 用戶登入
    private var authService: MQTTAuthService!
    
    // MARK: - 智慧環控
    private var smartService: MQTTSmartControlService!
    
    // MARK: - 五大設備
    private var deviceService: MQTTDeviceService!
    
    // MARK: - 五大設備
    private var decisionService: MQTTDecisionService!
    
    // MARK: - 用戶 token
    //    private var userToken: String {
    //        UserDefaults.standard.string(forKey: "MQTTAccessToken") ?? ""
    //    }
    
    //  MARK: - 加載
    private override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        let clientID = "iOS_Client_\(UUID().uuidString.prefix(6))"
        connectionService = MQTTConnectionService(
            clientID: clientID,
            host: "openenergyhub.energy-active.org.tw",
            port: 1884
        )
        connectionService.setDelegate(self)
        
        authService = MQTTAuthService(mqtt: connectionService.instance, appID: appID)
        
        // 啟動 智慧環控 服務
        smartService = MQTTSmartControlService(
            mqtt: connectionService.instance,
            userTokenProvider: {
                return userToken ?? ""
            }
        )
        
        // 啟動 五大設備 服務
        deviceService = MQTTDeviceService(
            mqtt: connectionService.instance,
            userTokenProvider: {
                return userToken ?? ""
            }
        )
        
        // 啟動 確認用戶接受AI服務 服務
        decisionService = MQTTDecisionService(
            mqtt: connectionService.instance,
            userTokenProvider: { 
                return userToken ?? ""
            }
        )
        
    }
    
    // MARK: - 對外公開操作
    // [對外]
    func connect() {
        connectionService.connect()
    }
    
    // [對外]
    func disconnect() {
        connectionService.disconnect()
    }
    
    // [對外]
    func login(username: String, password: String) {
        authService.publishLogin(username: username, password: password)
    }
    
    // [對外]
    //    func subscribeAuth() {
    //        authService.subscribe()
    //    }
    
    // [對外]
    func bindSmartDevice(mac: String) {
        smartService.publishBind(deviceMac: mac)
    }
    
    // [對外]
    func unbindSmartDevice(mac: String) {
        smartService.publishUnbind(deviceMac: mac)
    }
    
    // [對外]
    func requestCapabilities() {
        deviceService.publishRequestCapabilities()
    }
    
    // [對外]
    func setDeviceControl(model: [String: Any]) {
        deviceService.publishSetDeviceControl(model: model)
    }
    
    // [對外]
    func startTelemetry() {
        deviceService.publishTelemetryCommand(subscribe: true)
    }
    
    // [對外]
    func stopTelemetry() {
        deviceService.publishTelemetryCommand(subscribe: false)
    }
    
    // [對外]
    func setDecisionAccepted(accepted: Bool) {
        decisionService.publishDecisionAccepted(accepted)
    }
    
}

// MARK: - CocoaMQTTDelegate 實作
extension MQTTManagerMiddle: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("✅ MQTT 已連線 ack: \(ack)")
        
        // MARK: - 開始訂閱
        if ack == .accept {
            DispatchQueue.main.async {
                self.isConnected = true
            }
            self.authService.subscribe()
            self.smartService.subscribe()
            self.deviceService.subscribeAll()
            self.decisionService.subscribeAll()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📩 收到訊息：\(message.topic)")
        
        let topic = message.topic
        guard let payload = message.string else { return }
        
        // MARK: - 登入回應
        if topic == "to/app/\(appID)/authentication" {
            DispatchQueue.main.async {
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let success = json["success"] as? Bool {
                        self.loginResponse = String(success)
                    }
                    if let token = json["application_access_token"] as? String {
                        UserDefaults.standard.set(token, forKey: "MQTTAccessToken")
                    }
                }
            }
        }
        
        // MARK: - Smart 回應
        if topic == "to/app/\(userToken)/appliance/edge" {
            // 可加 smart 綁定狀態解析
            print("📬 收到智慧環控 edge 回應: \(payload)")
        }
        
        // MARK: - 讀寫能力 回應
        if topic == "to/app/\(userToken)/appliances/capabilities" {
            DispatchQueue.main.async {
                guard let data = payload.data(using: .utf8) else { return }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ApplianceCapabilitiesResponse.self, from: data)
                    self.deviceCapabilities = response.capabilities
                } catch {
                    print("❌ Capabilities 解碼失敗: \(error)")
                }
            }
        }
        
        // MARK: - 總設備所有資料 回應
        if topic == "to/app/\(userToken)/appliances/telemetry" {
            DispatchQueue.main.async {
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    print("✅ 總家電參數更新: \(json)")
                    print("✅ 總家電參數為空: \(json.isEmpty)")
                    
                    self.serverLoading = json.isEmpty
                    
                    if let availableDevices = json["availables"] as? [String] {
                        self.availables = availableDevices
                    }
                    
                    if let edgeBind = json["edge_bind"] as? Bool {
                        self.isSmartBind = edgeBind
                    }
                    
                    if let decisionConfig = json["decision_config"] as? Bool {
                        self.decisionEnabled = decisionConfig
                    }
                    
                    if let appliancesData = json["appliances"] as? [String: [String: Any]] {
                        var parsed: [String: [String: ApplianceData]] = [:]
                        
                        for (device, parameters) in appliancesData {
                            var deviceData: [String: ApplianceData] = [:]
                            for (param, value) in parameters {
                                let valueStr = String(describing: value)
                                let updated = parameters["updated"].flatMap { String(describing: $0) } ?? ""
                                deviceData[param] = ApplianceData(value: valueStr, updated: updated)
                            }
                            parsed[device] = deviceData
                        }
                        
                        self.appliances = parsed
                        
//                        print("✅ 成功接收到家電資料: \(self.appliances)")
                        if let mqtt_data = parsed["dehumidifier"] {
//                            print("✅ 「sensor」溫濕度數據: \(mqtt_data)")
//                            print("✅ 「air_conditioner」冷氣數據: \(mqtt_data)")
                            print("✅ 「dehumidifier」除濕機數據: \(mqtt_data)")
//                            print("✅ 「sensor」遙控器數據: \(mqtt_data)")

                        }
                    }
                }
            }
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("\(state == .connected ? "✅" : "⚠️") MQTT 狀態變更: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("📤 已發布訊息：\(message.string ?? "")")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("📬 發布確認 ID：\(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("📡 訂閱成功 topic：\(success.allKeys)")
        if !failed.isEmpty {
            print("❗ 訂閱失敗 topic：\(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("📭 取消訂閱 topic：\(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("🔃 發送 PING")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("🔁 收到 PONG")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
        print("❌ MQTT 斷線：\(err?.localizedDescription ?? "未知錯誤")")
    }
}
