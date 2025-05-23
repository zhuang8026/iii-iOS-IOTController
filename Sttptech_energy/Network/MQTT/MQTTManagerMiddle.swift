import Foundation
import CocoaMQTT
import Combine

// MARK: - 主要
final class MQTTManagerMiddle: NSObject, ObservableObject {
    static let shared = MQTTManagerMiddle()
    
    // MARK: - MQTT連線狀態
    @Published var isConnected: Bool = false
    // MARK: - Smart Control 連線狀態
    @Published var isSmartBind: Bool = false
    // MARK: - 設備綁定紀錄
    @Published var appBinds: [String: Any] = [:]
    // MARK: - AI決策 是否同意 AI控制狀態
    @Published var decisionEnabled: Bool = false
    // MARK: - AI決策alert開啟
    @Published var decisionControl: Bool = false
    // MARK: - AI決策啟動 && 用戶要關閉AI決策
    @Published var showDeviceAlert: Bool = false
    // MARK: - AI決策建議內容顯示
    @Published var decisionMessage: String = ""
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
    private var userToken: String {
        UserDefaults.standard.string(forKey: "MQTTAccessToken") ?? ""
    }
    
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
                return self.userToken ?? ""
            }
        )
        
        // 啟動 五大設備 服務
        deviceService = MQTTDeviceService(
            mqtt: connectionService.instance,
            userTokenProvider: {
                return self.userToken ?? ""
            }
        )
        
        // 啟動 確認用戶接受AI服務 服務
        decisionService = MQTTDecisionService(
            mqtt: connectionService.instance,
            userTokenProvider: {
                return self.userToken ?? ""
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
    
    // [對外] 設定設備資料
    func setDeviceControl(model: [String: Any]) {
        print("🚀🚀🚀 送出控制家電設定 >>>>>>>>>>>>>>")
        deviceService.publishSetDeviceControl(model: model)
        
        // decisionEnabled -> true, 說明「AI決策啟動」中並在「畫面上顯示」
        if(self.decisionEnabled){
            self.showDeviceAlert = true // 關閉 -> AI決策提示
            self.setDecisionAccepted(accepted: false) // 關閉AI決策MQTT
            
            AlertHelper.showAlert(title: "能源管家提示", message: "AI決策已關閉"){
                self.decisionEnabled = false // 關閉UI AI決策 文字
            }
        }
    }
    
    // [對外] 紀錄設備紀錄時間
    // 只需要 air_conditioner & dehumidifier
    func setRecord(appBind: String) {
        print("🚀🚀🚀 送出\(appBind)紀錄時間 >>>>>>>>>>>>>>")
        deviceService.publishSetRecord(appBind: appBind)
        
    }
    
    // [對外]
    func startTelemetry() {
        self.serverLoading = true // 環控頁面loading
        deviceService.publishTelemetryCommand(subscribe: true)
    }
    
    // [對外]
    func stopTelemetry() {
        deviceService.publishTelemetryCommand(subscribe: false)
    }
    
    // [對外] 是否開啟AI決策
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
            
            // self.authService.subscribe()      // v1 關閉 - 訂閱: 用戶登入
            self.smartService.subscribe()        // 訂閱: 智慧環控
            self.deviceService.subscribeAll()    // 訂閱: 取得家電所有資料、設備參數讀寫能力、發送與設定設備
            self.decisionService.subscribeAll()  // 訂閱: 用戶是否接受 AI 執行
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
        
        // MARK: - AI決策建議 回應
        if topic == "to/app/\(userToken)/appliances/decision/notify" {
            guard let data = payload.data(using: .utf8) else { return }
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let res = response, !res.isEmpty {
                    print("✅ AI決策建議 回應: \(res)")
                    
                    // 文字轉換
                    let message = returnAIDecisionText(from: res)
                    // ✅ 成功取得並推送通知
                    sendLocalNotification(title: "執行AI決策", body: message)
                    // ✅ 啟動alert視窗
                    self.decisionMessage = message
                    self.decisionControl = true
                } else {
                    print("⚠️ 回傳資料為空，略過通知")
                }
            } catch {
                print("❌ 家電能力 解碼失敗: \(error)")
            }
        }
        
        // MARK: - 讀寫能力 回應
        if topic == "to/app/\(userToken)/appliances/capabilities" {
            DispatchQueue.main.async {
                guard let data = payload.data(using: .utf8) else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ApplianceCapabilitiesResponse.self, from: data)
                    self.deviceCapabilities = response.capabilities
                    
                    print("家電能力: \(self.deviceCapabilities)")
                } catch {
                    print("❌ 家電能力 解碼失敗: \(error)")
                }
            }
        }
        
        // MARK: - 總設備所有資料 回應
        if topic == "to/app/\(userToken)/appliances/telemetry" {
            DispatchQueue.main.async {
                if let data = payload.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            print("✅ 總家電參數更新: \(json)")
                            //  print("✅ 總家電參數: \(json.isEmpty ? "無資料": "有資料")")
                            
                            self.serverLoading = json.isEmpty // 資料為空
                            self.serverLoading = json["error"] != nil // 出現error
                            // ✅ 檢查是否出現 error
                            if let errorMessage = json["error"] as? String {
                                self.serverLoading = false
                                print("❗發生錯誤：\(errorMessage)")
                                AlertHelper.showAlert(title: "錯誤通知", message: "\(errorMessage)")
                            } else {
                                // ✅ 無錯誤，正常更新
                                self.serverLoading = json.isEmpty
//                                print("MQTT 是否已取得資料: \(self.serverLoading)")
                            }
                            
                            // 已綁定家電 確認
                            if let availableDevices = json["availables"] as? [String] {
                                self.availables = availableDevices
                            }
                            
                            // 環控綁定 確認
                            if let edgeBind = json["edge_bind"] as? Bool {
                                self.isSmartBind = edgeBind
                            }
                            
                            // 設備綁定紀錄 確認
                            if let rawBinds = json["app_binds"] as? [String: Any] {
                                var result: [String: String] = [:]
                                for (key, value) in rawBinds {
                                    if let str = value as? String, str != "<null>" {
                                        result[key] = str
                                    } else {
                                        result[key] = "" // 或者不要加進去，用 continue 過濾掉
                                    }
                                }
                                self.appBinds = result
                                print("設備綁定紀錄:\(self.appBinds)")
                            }
                            
                            // AI決策啟動 確認
                            if let decisionConfig = json["decision_config"] as? Bool {
                                self.decisionEnabled = decisionConfig
                            }
                            
                            // 所有設備資料 取得
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
                                //                        if let mqtt_data = parsed["dehumidifier"] {
                                //                            print("✅ 「sensor」溫濕度數據: \(mqtt_data)")
                                //                            print("✅ 「air_conditioner」冷氣數據: \(mqtt_data)")
                                //                            print("✅ 「dehumidifier」除濕機數據: \(mqtt_data)")
                                //                            print("✅ 「sensor」遙控器數據: \(mqtt_data)")
                                
                                //                        }
                            }
                        }
                    } catch {
                        print("❗JSON 解析錯誤: \(error.localizedDescription)")
                    }
                } else {
                    print("❗payload 無法轉成 UTF-8 Data: \(payload)")
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
        print("🔵 發布確認 ID：\(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("📡 訂閱成功 topic：\(success.allKeys)")
        if !failed.isEmpty {
            print("❗ 訂閱失敗 topic：\(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("🔴 取消訂閱 topic：\(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("🔵 發送 PING")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("🟢 收到 PONG")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
        print("❌ MQTT 斷線：\(err?.localizedDescription ?? "未知錯誤")")
    }
}

// MARK: - AI決策建議 整合功能
func returnAIDecisionText(from data: [String: Any]) -> String {
    var socketAI = "" // 插座
    var airconAI = "" // 冷氣
    var dehumidifierAI = "" // 除濕機
    var aiReply = "" // 用戶使用
    var result = ""  // 工程人員測試用，已關閉使用
    
    // MARK: - ac_outlet
    if let outlet = data["ac_outlet"] as? [String: Any],
       let power = outlet["cfg_power"] as? String {
        socketAI = "\(translateStringToChinese(power))"
        result += "插座電源：\(translateStringToChinese(power))\n"
    }
    
    // MARK: - air_conditioner
    if let aircon = data["air_conditioner"] as? [String: Any] {
        if let power = aircon["cfg_power"] as? String, power != "<null>" {
            result += "冷氣電源：\(translateStringToChinese(power))\n"
        }
        
        if let mode = aircon["cfg_mode"] as? String, mode != "<null>" {
            result += "冷氣模式：\(translateStringToChinese(mode))\n"
        }
        
        if let fanLevel = aircon["cfg_fan_level"] as? String, fanLevel != "<null>" {
            airconAI += "風速\(translateStringToChinese(fanLevel))"
            result += "冷氣風速：\(translateStringToChinese(fanLevel))\n"
        }
        
        if let temp = aircon["cfg_temperature"] {
            let value = String(describing: temp)
            if value != "<null>" {
                airconAI += "調到\(value)度"
                result += "冷氣設定溫度：\(value) 度\n"
            }
        }
        
        if let opTemp = aircon["op_temperature"] {
            let value = String(describing: opTemp)
            if value != "<null>" {
                result += "冷氣操作溫度：\(value) 度\n"
            }
        }
    }
    
    // MARK: - dehumidifier
    if let dehumidifier = data["dehumidifier"] as? [String: Any] {
        if let power = dehumidifier["cfg_power"] as? String {
            result += "除濕機電源：\(translateStringToChinese(power))\n"
        }
        
        if let mode = dehumidifier["cfg_mode"] as? String {
            dehumidifierAI += "模式\(translateStringToChinese(mode))"
            result += "除濕機模式：\(translateStringToChinese(mode))\n"
        }
        
        if let fan = dehumidifier["cfg_fan_level"] as? String {
            dehumidifierAI += "風速\(translateStringToChinese(fan))"
            result += "除濕機風速：\(translateStringToChinese(fan))\n"
        }
        
        if let humidity = dehumidifier["cfg_humidity"] {
            dehumidifierAI += "設定濕度\(humidity)% "
            result += "除濕機設定濕度：\(humidity)%\n"
        }
        
        if let timer = dehumidifier["cfg_timer"] {
            result += "除濕機定時設定：\(timer) 小時\n"
        }
        
        if let opHumidity = dehumidifier["op_humidity"] {
            result += "除濕機操作濕度：\(opHumidity)%\n"
        }
        
        if let alarm = dehumidifier["op_water_full_alarm"] as? String {
            result += "\(translateStringToChinese(alarm))\n"
        }
    }
    
    // MARK: - 書安通知寫死這句話 20250521
    aiReply = "依照您現在的室溫、濕度狀態，我們建議把\(airconAI != "" ? "冷氣\(airconAI)" : "")\(dehumidifierAI != "" ? "，除濕機\(dehumidifierAI)" : "")\(socketAI != "" ? "，再將電扇\(socketAI)" : "")，這樣就能因應環境變化，保持涼爽舒適，又輕鬆省電，快試試看吧！"
    
    return aiReply.trimmingCharacters(in: .whitespacesAndNewlines)
    
    //    return result.trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - 中文轉換工具
func translateStringToChinese(_ val: String) -> String {
    switch val {
        // 開關
    case "on":     return "開啟"
    case "off":    return "關閉"
        
        // 冷氣模式
    case "cool":    return "冷氣"
    case "heat":    return "暖風"
    case "dry":     return "除濕"
        //    case "fan":     return "送風"
    case "auto":    return "自動"
        
        // 除濕機
        //    case "auto": return "自動除濕"
    case "manual": return "自訂除濕"
    case "continuous": return "連續除濕"
    case "clothes_drying": return "強力乾衣"
    case "purification": return "空氣淨化"
    case "sanitize": return "防霉抗菌"
    case "fan": return "空氣循環"
    case "comfort": return "舒適除濕"
    case "low_drying": return "低溫乾燥"
        
        // 風速強度
    case "low":     return "低"
    case "medium":  return "中"
    case "high":    return "高"
    case "strong":  return "強"
    case "max":     return "最強"
        
        // 水位
    case "alarm":   return "⚠️ 滿水警報"
    case "normal":  return "✅ 水位正常"
        
    default:        return "未知"
    }
}
