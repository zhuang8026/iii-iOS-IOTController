//
//  BluetoothController.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/7.
//
import Foundation
import CoreBluetooth

struct DiscoveredPeripheral: Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral
    let name: String?
    var rssi: Int
}

struct WiFiNetwork: Identifiable, Codable {
    let id = UUID()
    let ssid: String
    let rssi: Int
    let enc: String

    private enum CodingKeys: String, CodingKey {
        case ssid, rssi, enc
    }
}

struct DeviceWiFiInfo: Codable {
    let mac: String
    let wifi: [WiFiNetwork]
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isScanning: Bool = false // 藍芽搜尋狀態
    @Published var isBluetoothEnabled: Bool = false // // 藍芽是否被開啟
    @Published var discoveredPeripherals: [DiscoveredPeripheral] = [] // v2
    @Published var connectedPeripheral: CBPeripheral?
    @Published var deviceMac: String? // ✅ 設備 Wi-Fi MAC
    @Published var wifiNetworks: [WiFiNetwork] = [] // ✅ Wi-Fi 掃描結果
    @Published var wifiSetupStatus: String? // ✅ Wi-Fi 設定狀態

    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic? // ✅ 用來寫入 SSID/PWD


    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    // 步驟 1：使用 CoreBluetooth 掃描藍牙設備
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothEnabled = (central.state == .poweredOn)
        }
//        if central.state == .poweredOn {
//            startScanning()
//        } else {
//            print("⚠️ 藍牙未開啟或不可用")
//        }
    }

    func startScanning() {
        print("🔍 開始掃描藍牙設備...")
        DispatchQueue.main.async {
            self.isScanning = true
            print("🔍 開始掃描藍牙 loading status: \(self.isScanning)")
        }
        discoveredPeripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        // 設置一個超時機制，假設 10 秒後自動停止掃描
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.stopScanning()
        }
    }

    func stopScanning() {
        print("🛑 停止掃描")
        centralManager.stopScan()
        DispatchQueue.main.async {
            self.isScanning = false
            print("🛑 停止掃描藍牙 loading status: \(self.isScanning)")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            // 檢查 peripheral.name 是否存在，並且以 "ST" 開頭
            if let name = peripheral.name, name.hasPrefix("ST") {
               if let index = self.discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
                   // 如果設備已存在，更新 RSSI
                   self.discoveredPeripherals[index].rssi = RSSI.intValue
               } else {
                   // 如果是新設備，加入陣列
                   let discoveredPeripheral = DiscoveredPeripheral(peripheral: peripheral, name: name, rssi: RSSI.intValue)
                   self.discoveredPeripherals.append(discoveredPeripheral)
               }
            }
        }

//        print("📡 發現設備: \(peripheral.name ?? "未知設備") with RSSI: \(RSSI) and \(peripheral.identifier)")
    }
    
    // 步驟 2：連接到特定的藍牙設備
    func connectToDevice(_ peripheral: CBPeripheral) {
        targetPeripheral = peripheral
        targetPeripheral?.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
        }
        print("✅ 已連接: \(peripheral.name ?? "設備")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("❌ 連接失敗: \(error?.localizedDescription ?? "未知錯誤")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.connectedPeripheral = nil
        }
        print("⚠️ 連線中斷: \(peripheral.name ?? "設備")")
    }
    
    // 步驟 3：透過藍牙獲取 Wi-Fi 列表
    // 找尋設備
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("❌ 發現服務錯誤: \(error!.localizedDescription)")
            return
        }

        for service in peripheral.services ?? [] {
            print("📡 找到服務: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // 讀取 Wi-Fi function || FEF4 Read || FEF5 Write
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("❌ 發現特徵錯誤: \(error!.localizedDescription)")
            return
        }

        for characteristic in service.characteristics ?? [] {
             print("🔎 找到特徵: \(characteristic.uuid) - 屬性: \(characteristic.properties)")
                
            // ✅ `FEF4` 為 Read Characteristic (讀取 Wi-Fi 資訊)
            if characteristic.uuid == CBUUID(string: "FEF4"), characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            // ✅ `FEF5` 為 Write Characteristic (寫入 "scan")
            if characteristic.uuid == CBUUID(string: "FEF5") {
                if characteristic.properties.contains(.write) {
                    print("✅ `FEF5` 支援 `.write`")
                    print("✅ 設置 Write 特徵: \(characteristic.uuid)")
                    self.writeCharacteristic = characteristic
                    let command = "scan"
                    if let data = command.data(using: .utf8) {
                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
                        print("📡 已發送 'scan' 指令至 FEF5")
                    }
                }
                if characteristic.properties.contains(.writeWithoutResponse) {
                    print("⚠️ `FEF5` 只支援 `.writeWithoutResponse`，不會觸發 `didWriteValueFor`")
                }
            }
            
        }
    }
    
    // 更新 didUpdateValueFor 方法
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("❌ 讀取特徵錯誤: \(error!.localizedDescription)")
            return
        }

        if let data = characteristic.value {
            if let jsonString = String(data: data, encoding: .utf8) {
//                print("📶 Wi-Fi JSON 回應: \(jsonString)")

                // 解析 JSON
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        let deviceWiFiInfo = try JSONDecoder().decode(DeviceWiFiInfo.self, from: jsonData)
                        
                        DispatchQueue.main.async {
                            self.deviceMac = deviceWiFiInfo.mac
                            self.wifiNetworks = deviceWiFiInfo.wifi
                        }

                        print("✅ 解析成功！Wi-Fi MAC: \(deviceWiFiInfo.mac)")
                        for network in deviceWiFiInfo.wifi {
                            print("📡 SSID: \(network.ssid), RSSI: \(network.rssi), 加密方式: \(network.enc)")
                        }
                    } catch {
                        print("⚠️ JSON 解析失敗: \(error.localizedDescription)")
                        self.deviceMac = ""
                        self.wifiNetworks = []
                    }
                }
            }
        }
        
        if characteristic.uuid == CBUUID(string: "FEF4"), let data = characteristic.value {
           if let result = String(data: data, encoding: .utf8) {
               print("📶 Wi-Fi 設定結果: \(result)")

               DispatchQueue.main.async {
                   if result.contains("success") {
                       self.wifiSetupStatus = "✅ Wi-Fi 設定成功！"
                   } else {
                       self.wifiSetupStatus = "⚠️ 設定失敗：\(result)"
                   }
               }
           }
       }

    }
    
    // 步驟 4：輸入Wi-Fi && Wi-Fi密碼
    // ✅ **寫入 SSID**
    func writeSSID(_ ssid: String) {
        print("📡 嘗試寫入 SSID: \(ssid)")

        guard let peripheral = connectedPeripheral else {
            print("⚠️ 無法寫入 SSID，設備未連接")
            return
        }

        guard let characteristic = writeCharacteristic else {
            print("⚠️ 無法寫入 SSID，未發現 `writeCharacteristic`")
            return
        }

//        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
//            print("⚠️ 無法寫入 SSID，藍牙未連接")
//            return
//        }

        let ssidCommand = "ssid\(ssid)" // ex: ssidHH42CV_19D7
        if let data = ssidCommand.data(using: .ascii) { // using: .utf8, .ascii, .windowsCP1252
            let hexString = data.map { String(format: "%02X", $0) }.joined(separator: " ")
            print("📡 SSID Data (HEX): \(hexString)")

            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("✅ 已寫入Wi-Fi SSID📡: \(data)")
            wifiSetupStatus = "正在設定 Wi-Fi..."
        }
    }

    // ✅ **寫入密碼**
    func writePassword(_ password: String) {
        print("🔑 嘗試寫入 Wi-Fi 密碼: \(password)")

        guard let peripheral = connectedPeripheral else {
            print("⚠️ 無法寫入密碼，設備未連接")
            return
        }

        guard let characteristic = writeCharacteristic else {
            print("⚠️ 無法寫入密碼，未發現 `writeCharacteristic`")
            return
        }

        let pwdCommand = "pwd\(password)" // ex: pwd0987654321
        if let data = pwdCommand.data(using: .ascii) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("✅ 已寫入 Wi-Fi 密碼🔑: \(data)")
        }
    }

    // ✅ **監聽寫入結果**
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ 寫入錯誤: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.wifiSetupStatus = "設定失敗"
            }
            return
        }

        if characteristic.uuid == CBUUID(string: "FEF4") { // FEF5
            print("✅ 寫入成功: \(characteristic.uuid)")
            DispatchQueue.main.async {
                self.wifiSetupStatus = "設定成功！"
            }
        }
    }

}
