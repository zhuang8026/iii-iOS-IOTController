//
//  MQTTManager.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/3.
//

import SwiftUI
import CocoaMQTT

// MARK: - [對外] 核心功能
class MQTTManager: NSObject, ObservableObject {
    static let shared = MQTTManager()
    
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
    
    let AppID = "1d51e92d-e623-41dd-b367-d955a0d44d66" // 測試使用
    var userToken:String = "IljLTCU3Ba0kVGqx3ouxrjydiZChGJGCvNvyp2WrzAN4aCz3aROJ9oKVkalMR56Rz6oBTfHHT9nGLTXQwIhw2jl1YIL4Ad4d3oFd9zhGYyMzf3qiQVuNZcnbdytwIAmM6Up881IdNx8GIOxgVISl4ecGzIY71AqnEVuaYgKwrxbECn95KOQIZHiKTWka8Er0jVMhPx32bsjpV5IdUYPNOIygnqcbnXVZbc2LrU7mBUYKgHEWs54NO7GITD0kSCwQjBaMwY6F8jl6QG70xGGtoiBesBbzwybXV0AQtCIKN8l5ki4yg4DyEiaRRifL7AMJ5cDXDzJg0zIItGHGcnUYLSrFyXasIw905igrKKDrBe2B0qUiTCRbifH0JQ5gA9IT8F9ij7GFhl7UHAEtuReTdvfTqzl" // 測試 Token
    
    var mqtt: CocoaMQTT?
    
    func connectMQTT() {
        let clientID = "iOS_Client_\(UUID().uuidString.prefix(6))"
        mqtt = CocoaMQTT(clientID: clientID, host: "openenergyhub.energy-active.org.tw", port: 1884) // ex: host: "broker.hivemq.com", port: 1884
        mqtt?.username = "app"      // username: "app"
        mqtt?.password = "app:ppa"  // password: "app:ppa"
        mqtt?.delegate = self
        // print("⏰ 準備連線 MQTT")
        if let isConnected = mqtt?.connect() {
            // print("🚀 MQTT 連線狀態: \(isConnected ? "成功" : "失敗")")
        }
    }
    
    func disconnectMQTT() {
        mqtt?.disconnect()
        // print("🔴 MQTT 已斷線")
    }
    
    // MARK: - 讀取 UserDefaults 中的 Token - energy v2 暫時關閉
    private func loadStoredUserToken() {
        if let token = UserDefaults.standard.string(forKey: "MQTTAccessToken") {
            //  print("🔑 讀取到存儲的 Token: \(token)")
            userToken = token
        } else {
            // print("⚠️ 找不到儲存的 Token")
        }
    }
    
    // MARK: - 登入 - energy v2 暫時關閉
    // 訂閱「登入」訂閱結果的 topic - energy v2 暫時關閉
    func subscribeToAuthentication() {
        mqtt?.subscribe("to/app/\(AppID)/authentication", qos: .qos1) // API
        // print("📡 開始訂閱「登入」頻道：to/app/\(AppID)/authentication")
        // print("📡 訂閱登入頻道: 成功")
    }
    
    // 發布「登入」發送指令 - energy v2 暫時關閉
    func publishApplianceUserLogin(username: String, password: String) {
        guard isConnected else {
            // print("❌ MQTT 未連線，無法發送登入指令")
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
            mqtt?.publish("from/app/\(AppID)/authentication", withString: jsonString, qos: .qos1, retained: false)
            // print("📤 發送登入指令至 from/app/\(AppID)/authentication")
        } else {
            // print("❌ JSON 轉換失敗")
        }
    }
    
    // MARK: - 檢查 智慧環控 連線狀態
    // 訂閱「智慧環控連接」訂閱結果的 topic
    func subscribeToSmart() {
        mqtt?.subscribe("to/app/\(userToken)/appliance/edge", qos: .qos1) // API
        // print("📡 開始訂閱「智慧環控連接」頻道：to/app/\(userToken)/appliance/edge")
        // print("📡 訂閱登入頻道: 成功")
    }
    
    // 發布 - 綁定「智慧環控連接」發送指令
    func publishBindSmart(deviceMac: String) {
        guard isConnected else {
            // print("❌ MQTT 未連線，無法發送 智慧環控連接 指令")
            return
        }
        
        let payload: [String: String] = [
            "bind": deviceMac, // 綁定指令
        ]
        
        // print("📤 發送綁定「智慧環控」Mac代碼 -> \(payload)") // 綁定指令 -> "bind": "{環控主機唯一識別碼}"
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt?.publish("from/app/\(userToken)/appliance/edge", withString: jsonString, qos: .qos1, retained: false)
            // print("📤 發送登入指令至 from/app/\(userToken)/appliance/edge")
        } else {
            // print("❌ JSON 轉換失敗")
        }
    }
    
    // 發布 - 解除綁定「智慧環控連接」發送指令
    func publishUnBindSmart(deviceMac: String) {
        guard isConnected else {
            // print("❌ MQTT 未連線，無法發送 智慧環控連接 指令")
            return
        }
        
        let payload: [String: String] = [
            "unbind": deviceMac, // 解除綁定指令
        ]
        
        // print("📤 發送解除「智慧環控」Mac代碼 -> \(payload)") // 解除綁定指令 -> "unbind": "{環控主機唯一識別碼}"
        
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt?.publish("from/app/\(userToken)/appliance/edge", withString: jsonString, qos: .qos1, retained: false)
            // print("📤 發送登入指令至 from/app/\(userToken)/appliance/edge")
        } else {
            // print("❌ JSON 轉換失敗")
        }
    }
    
    // MARK: - 取得 "有所設備參數讀寫能力"
    // 訂閱 家電參數讀寫能力 資訊
    func subscribeToCapabilities() {
        let topic = "to/app/\(userToken)/appliances/capabilities" // API
        mqtt?.subscribe(topic)
        // print("📡 訂閱家電資訊: \(topic)")
    }
    
    // 發布 查詢 家電參數讀寫能力 指令
    func publishCapabilities() {
        let topic = "from/app/\(userToken)/appliances/capabilities" // API
        
        // 確保 payload 在 userToken 更新後才建立
        let payload: [String: Any] = ["appliance": NSNull()]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            mqtt?.publish(topic, withString: jsonString)
            // print("🚀 發送查詢 家電參數讀寫能力 指令: \(jsonString)")
        } catch {
            // print("❌ JSON 家電參數讀寫能力 error: \(error)")
        }
    }
    
    // MARK: - 有所設備資料
    // 訂閱家電資訊
    func subscribeToTelemetry() {
        let topic = "to/app/\(userToken)/appliances/telemetry" // API
        mqtt?.subscribe(topic)
        // print("📡 訂閱家電資訊: \(topic)")
    }
    
    //  發布 開始 or 停止 接收家電資訊指令
    func publishTelemetryCommand(subscribe: Bool) {
        let topic = "from/app/\(userToken)/appliances/telemetry" // API
        
        // 確保 payload 在 userToken 更新後才建立
        let payload: [String: Any] = ["token": userToken, "subscribe": subscribe]
        
        // print("⭐ 讀取到存儲的 payload: \(payload)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt?.publish(topic, withString: jsonString)
            // print("🚀 發送 \(subscribe ? "開始" : "停止") 接收家電資訊指令: \(jsonString)")
        }
    }
    
    // MARK: - 發送與設定設備
    // 訂閱「設定裝置」資訊
    func subscribeToSetDeviceControl() {
        let topic = "to/app/\(userToken)/appliances/control" // API
        mqtt?.subscribe(topic)
        // print("📡 訂閱「設定裝置」資訊: \(topic)")
    }
    
    // 發布「設定裝置」發送指令
    func publishSetDeviceControl(model: [String: Any]) {
        guard isConnected else {
            // print("❌ MQTT 未連線，無法發送登入指令")
            return
        }
        
        // 確保 payload 在 userToken 更新後才建立
        let payload: [String: Any] = [
            "token": userToken,
            "appliances": model,  // ✅ 正確使用 Dictionary
            //            "appliances": [
            //                "air_conditioner": [
            //                    "ac_outlet": [
            //                        "cfg_power": "off"
            //                    ]
            //
            //                ]
            //            ],
            "success": true
        ]
        
        // print("⭐ 讀取到存儲的 「設定裝置: \(payload)")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt?.publish("from/app/\(userToken)/appliances/control", withString: jsonString, qos: .qos1, retained: false)
            // print("📤 發送「設定裝置」指令至 from/app/\(userToken)/appliances/control")
        } else {
            // print("❌ JSON 轉換失敗")
        }
    }
    
    // MARK: - 未定案 用戶是否接受 AI 執行
    // 訂閱「回報成功與否」資訊
    func subscribeDecisionConfig() {
        let topic = "to/app/\(userToken)/appliances/decision/config" // API
        mqtt?.subscribe(topic)
        // print("📡 訂閱「是否接受 AI 執行」資訊: \(topic)")
    }
    
    // 發布「用戶接受調控與否」發送指令
    func publishSetDecisionConfig(accepted: Bool) {
        guard isConnected else {
            // print("❌ MQTT 未連線，無法發送登入指令")
            return
        }
        
        let payload: [String: Any] = [
            "accepted": accepted, // ture = 接受, alse = 不接受
        ]
        
        // print("⭐ 用戶接受調控與否: \(payload)")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt?.publish("from/app/\(userToken)/appliances/decision/config", withString: jsonString, qos: .qos1, retained: false)
            // print("📤 發送「設定裝置」指令至 from/app/\(userToken)/appliances/decision/config")
        } else {
            // print("❌ JSON 轉換失敗")
        }
    }
    
    // MARK: - 未定案 AI 已調控設備通知
    // 訂閱「AI 已調控完成」資訊
    func subscribeDecisionNotify() {
        let topic = "to/app/\(userToken)/appliances/decision/notify" // API
        mqtt?.subscribe(topic)
        // print("📡 訂閱「AI 已調控完成」資訊: \(topic)")
    }
}

// MARK: - [對內] 負責 MQTT 代理方法
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        // print("1️⃣ MQTT 連線成功: \(ack)")
        
        if ack == .accept {
            DispatchQueue.main.async {
                self.isConnected = true
            }
            // subscribeToAuthentication()     //「登入」連線後自動訂閱 - energy v2 暫時關閉
            subscribeToCapabilities()     // 家電參數讀寫能力
            subscribeToSmart()            //「環控主機」連線後自動訂閱
            subscribeToTelemetry()        //「溫濕度」連線後自動訂閱
            subscribeToSetDeviceControl() //「設定裝置」連線後自動訂閱
            subscribeDecisionConfig()     // [未定案]「是否接受AI決策」連線後自動訂閱
            subscribeDecisionNotify()     // [未定案]「 AI已決策玩笑通知」連線後自動訂閱
            
        } else {
            // print("❌ MQTT 連線失敗: \(ack)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        // print("⚠️ MQTT 狀態變更: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        // print("MQTT 消息已發布: \(message.string ?? "")")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        // print("MQTT 發布收到的 id 確認: \(id)")
    }
    
    
    // MARK: - 取得 API 回應
    // response data
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        //        print("MQTT 成功發送訊息:  \(message.string ?? "") 到 \(message.topic)")
        //        print("MQTT 成功發送訊息到 -> \(message.topic)")
        
        // MARK: - [用戶Token] 確保是訂閱的 登入 - energy v2 暫時關閉
        if message.topic == "to/app/\(AppID)/authentication", let payload = message.string {
            DispatchQueue.main.async {
                // 解析 JSON 取得 Token
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    // 取得 `success` 欄位的值
                    if let success = json["success"] as? Bool {
                        self.loginResponse =  String(success)
                    }
                    
                    // 取得 `application_access_token` 並存入 UserDefaults
                    if let token = json["application_access_token"] as? String {
                        UserDefaults.standard.set(token, forKey: "MQTTAccessToken")
                        //                        print("✅ Token 已儲存：\(token)")
                    }
                }
            }
            // print("✅ 登入回應: \(payload)")
        }
        
        // MARK: - [智慧環控] 確保是訂閱的 綁定智慧環控 - v1 || v2
        if message.topic == "to/app/\(userToken)/appliance/edge", let payload = message.string {
            DispatchQueue.main.async {
                // 解析 JSON 取得 Token
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    //                    print("智慧環控回報：\(json)")
                    // 取得 `success` 欄位的值
                    //                    if let success = json["success"] as? Bool {
                    //                        self.serverLoading = success
                    //                    }
                    //                    // 取得 `application_access_token` 並存入 UserDefaults
                    //                    if let token = json["application_access_token"] as? String {
                    //                        UserDefaults.standard.set(token, forKey: "MQTTAccessToken")
                    //                        //                        print("✅ Token 已儲存：\(token)")
                    //                    }
                }
            }
            //            print("✅ 綁定 智慧環控 回應: \(payload)")
        }
        
        // MARK: - [家電參數讀寫能力] 確保是訂閱 家電參數讀寫能力 - v1 || v2
        if message.topic == "to/app/\(userToken)/appliances/capabilities", let payload = message.string {
            DispatchQueue.main.async {
                guard let data = payload.data(using: .utf8) else {
                    // print("❌ Payload 轉換失敗")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ApplianceCapabilitiesResponse.self, from: data)
                    
                    // 環控綁定狀態
                    //                    print("✅ 環控綁定狀態: edgeBind = \(response.edgeBind)")
                    
                    // 裝置設定能力參數
                    //                    for (device, abilities) in response.capabilities {
                    //                        print("🔧 裝置: \(device)")
                    //                        for (capability, values) in abilities {
                    //                            print("- 能力:  => \(values)")
                    //                        }
                    //                    }
                    
                    // 設備綁定項目
                    //                    print("✅ 綁裝置列表: \(response.availables)")
                    
                    // 你可以在這裡將資料存入 ViewModel 或狀態管理
                    self.deviceCapabilities = response.capabilities
                    //                    print("✅ 裝置設定能力參數: \(self.deviceCapabilities)")
                    //                    if let mqtt_data = self.deviceCapabilities["dehumidifier"] {
                    //                        print("✅ 「sensor」溫濕度讀取能力: \(mqtt_data)")
                    //                        print("✅ 「air_conditioner」冷氣讀取能力: \(mqtt_data)")
                    //                        print("✅ 「dehumidifier」除濕機讀取能力: \(mqtt_data)")
                    //                        print("✅ 「remote」遙控器讀取能力: \(mqtt_data)")
                    
                    //                    }
                } catch {
                    // print("❌ JSON 解碼失敗: \(error)")
                }
            }
            // print("✅ 登入回應: \(payload)")
        }
        
        // MARK: - [接收家電資訊指令] 確保是訂閱 取得家電所有資料 - v1 || v2
        if message.topic == "to/app/\(userToken)/appliances/telemetry", let payload = message.string {
            DispatchQueue.main.async {
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    print("✅ [舊] 總家電參數更新: \(json)")
                    if json.isEmpty {
                        self.serverLoading = true
                        // print("⚠️ to/app/userToken/appliances/telemetry API 無資料")
                    } else {
                        self.serverLoading = false
                        // print("✅ 家電資料收集中")
                    }
                    
                    // MARK: - MenuBAR
                    // 解析 availables
                    if let availableDevices = json["availables"] as? [String] {
                        self.availables = availableDevices
                        // print("✅ 可用家電: \(availableDevices)")
                    }
                    
                    // MARK: - 智能環控綁定狀態
                    // 解析 edge_bind
                    if let edgeBind = json["edge_bind"] as? Bool {
                        self.isSmartBind = edgeBind
                        // print("✅ 智能環控綁定狀態: current status:\(edgeBind)")
                    }
                    
                    // MARK: - AI決策 - 用戶是否接受AI自動調控
                    // 解析 decision_config
                    if let decisionConfig = json["decision_config"] as? Bool {
                        self.decisionEnabled = decisionConfig
                        // print("✅ AI決策狀態: current status: \(decisionConfig)")
                    } else {
                        // print("⚠️ decision_config is null or not a Bool, no update.")
                    }
                    
                    // MARK: - 所有電器資料
                    // 解析 appliances
                    if let appliancesData = json["appliances"] as? [String: [String: Any]] {
                        var parsedAppliances: [String: [String: ApplianceData]] = [:]
                        
                        for (device, parameters) in appliancesData {
                            var deviceData: [String: ApplianceData] = [:]
                            for (param, value) in parameters {
                                //                                if param == "updated" {
                                //                                    continue // Skip the general updated field
                                //                                }
                                let valueStr = String(describing: value)
                                let updated = parameters["updated"].flatMap { String(describing: $0) } ?? ""
                                deviceData[param] = ApplianceData(value: valueStr, updated: updated)
                            }
                            parsedAppliances[device] = deviceData
                        }
                        
                        self.appliances = parsedAppliances
                        //                        print("✅ 總家電參數更新: \(parsedAppliances)")
                        
                        //                        if let mqtt_data = parsedAppliances["dehumidifier"] {
                        //                            print("✅ 「sensor」溫濕度數據: \(mqtt_data)")
                        //                            print("✅ 「air_conditioner」冷氣數據: \(mqtt_data)")
                        //                            print("✅ 「dehumidifier」除濕機數據: \(mqtt_data)")
                        //                            print("✅ 「sensor」遙控器數據: \(mqtt_data)")
                        
                        //                        }
                    }
                }
            }
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        // print("🎉 成功訂閱的 topic: \(success.allKeys)")
        if !failed.isEmpty {
            // print("🛑 訂閱失敗的 topic: \(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        // print("成功取消訂閱的 topic: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // print("🔜 MQTT Ping 發送請求成功")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // print("🔙 MQTT 收到 Pong 回應")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        // print("❌ MQTT 斷線: \(err?.localizedDescription ?? "未知錯誤")")
    }
}
