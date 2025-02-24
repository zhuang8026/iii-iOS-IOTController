//
//  BluetoothView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/8.
//

import SwiftUI
import CoreBluetooth

struct BluetoothView: View {
    @Binding var isPresented: Bool  // 綁定來控制顯示/隱藏
    @Binding var selectedTab: String // 標題名稱
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    @State private var isRotating = false // loading 旋轉動畫控制
    
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var selectedDevice: DiscoveredPeripheral? = nil // 存取選取藍芽裝置
    @State private var selectedSSID: String = ""
    @State private var wifiPassword: String = ""
    @State private var isEmpty: Bool = false
    
    @State private var deviceType = [
        "1": "冷氣機",
        "2": "電冰箱",
        "3": "洗衣機",
        "4": "除濕機",
        "5": "電視機",
        "6": "乾衣機",
        "7": "熱泵熱水器",
        "8": "空氣清淨機",
        "9": "電子鍋",
        "0A": "開飲機",
        "0B": "電磁爐",
        "0C": "烘碗機",
        "0D": "微波爐",
        "0E": "全熱交換器",
        "0F": "電扇",
        "10": "燃氣熱水器",
        "11": "燈具",
        "12": "居家顯示器",
        "13": "電動捲門",
        "14": "淨水器",
        "16": "暖風換氣扇",
        "17": "抽油煙機",
        "18": "瓦斯爐",
        "19": "IH 爐",
        "1A": "飲水機",
        "1B": "電動車充電樁",
        "F1": "智慧壁切開關",
        "FE": "紅外線發射器",
        "FF": "溫濕度感測器"
    ]
    
    func formatDeviceName(_ rawName: String) -> String {
        let components = rawName.split(separator: "_")
        
        // 確保至少有 4 個部分，避免崩潰
        guard components.count >= 4 else { return rawName }
        
        let typeCode = String(components[1]) // 例如 "FF"
        let modelCode = String(components[2]) // 例如 "GR2000"
        let identifier = String(components[3]) // 例如 "A4F144"
        
        // 查找設備類型名稱
        let deviceTypeName = deviceType[typeCode] ?? "未知設備"
        
        // 提取型號（去掉 "GR"，但保留後面的數字）
        let formattedModel = modelCode.hasPrefix("GR") ? "G" + modelCode.dropFirst(2) : modelCode
        
        // 組合最終顯示名稱
        return "\(deviceTypeName)(\(formattedModel))\(identifier)"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(selectedTab)裝置設定") // 「標題」
                    .font(.body)
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.forward") //「返回icon」
                    .foregroundColor(.g_blue)
                    .font(.system(size: 20)) // 调整图标大小
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false  // 退出畫面
                        }
                    }
            }
            
            //            if bluetoothManager.isBluetoothEnabled { Text("✅ 藍牙已開啟") } else { Text("❌ 藍牙未開啟") }
            
            if (bluetoothManager.discoveredPeripherals.isEmpty) { // 空藍芽資料
                VStack {
                    Spacer()
                    EmptyData()
                    Spacer()
                }
            } else if (bluetoothManager.isScanning) { // 掃描藍芽中
                VStack {
                    Spacer()
                    Loading()
                    Spacer()
                }
            } else {
                ScrollView {
                    if let selectedDevice = selectedDevice {
                        // 已選擇單一藍芽裝置
                        VStack(alignment: .leading, spacing: 10) {
                            // 顯示選擇的設備
                            Button(action: { print("no data")}) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(formatDeviceName(selectedDevice.name ?? "未知設備"))
                                            .font(.headline)
                                            .foregroundColor(Color.g_blue) // 設備名稱
                                        Spacer()
                                        Text(selectedDevice.peripheral.identifier.uuidString)
                                            .font(.subheadline)
                                            .foregroundColor(Color.heavy_gray) // 設備 UUID
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                //                                .background(Color.light_gray) // 按鈕背景顏色
                                //                                .cornerRadius(5) // 圓角
                            }
                            
                            // 🔹 分割線（新增）
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.white)
                                .padding(.vertical, 10)
                            
                            HStack {
                                Text("Wi-Fi 設定") // 「標題」
                                    .font(.body)
                                    .padding(.bottom, 10) // ✅ 設置與下面區塊的距離為 20
                            }
                            
                            // ✅ Wi-Fi 掃描結果 (允許選擇)
                            if bluetoothManager.wifiNetworks.isEmpty {
                                if isEmpty {
                                    HStack {
                                        Spacer()
                                        EmptyData(text: "未找到可用 Wi-Fi")
                                        Spacer()
                                    }
                                    
                                } else {
                                    HStack {
                                        Spacer()
                                        Loading(text: "尋找 Wi-Fi 中")
                                        Spacer()
                                    }
                                    .onAppear {
                                        // 10秒後檢查 Wi-Fi 列表是否還是空的
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                            if bluetoothManager.wifiNetworks.isEmpty {
                                                isEmpty = true
                                            }
                                        }
                                    }
                                }
                            } else {
                                // Wi-Fi列表
                                WiFiListView(bluetoothManager: bluetoothManager, selectedSSID: $selectedSSID, password: $wifiPassword, isConnected: $isConnected)
                            }
                        }
                    } else {
                        // 藍芽裝置列表
                        LazyVStack(spacing: 10) { // `LazyVStack` 會延遲載入，提高效能
                            ForEach(bluetoothManager.discoveredPeripherals, id: \.id) { discovered in
                                if let name = discovered.name {
                                    // 解析名稱
                                    let formattedName = formatDeviceName(name)
                                    
                                    Button(action: {
                                        self.isRotating = false // loading動畫還原
                                        selectedDevice = discovered // 設置選擇的設備
                                        bluetoothManager.connectToDevice(discovered.peripheral)
                                        triggerHapticFeedback(model: .heavy) // 觸發震動
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(formattedName)
                                                    .font(.headline)
                                                    .foregroundColor(Color.g_blue) // 設備名稱
                                                Spacer()
                                                Text(discovered.peripheral.identifier.uuidString)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color.heavy_gray) // 設備 UUID
                                            }
                                            //                                    Spacer()
                                            //                                    Text("RSSI: \(discovered.rssi)") // 訊號強度
                                            //                                        .foregroundColor(.yellow)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.light_gray) // 按鈕背景顏色
                                        .cornerRadius(5) // 圓角
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color.clear) // 設定整個 `ScrollView` 背景
            }
            
            
            // ✅ 顯示設備 MAC
            //            if let mac = bluetoothManager.deviceMac {
            //                VStack(alignment: .leading) {
            //                    Text("📶 設備 Wi-Fi MAC")
            //                        .font(.headline)
            //                    Text(mac)
            //                        .font(.body)
            //                        .padding()
            //                        .background(Color.gray.opacity(0.2))
            //                        .cornerRadius(10)
            //                }
            //                .padding()
            //            }
            
            // ✅ 輸入 Wi-Fi 密碼/Test-ok
            //            TextField("輸入 Wi-Fi 密碼", text: $wifiPassword)
            //                .textFieldStyle(RoundedBorderTextFieldStyle())
            //                .autocorrectionDisabled(true)
            //                .textInputAutocapitalization(.never)
            //                .padding()
            
            // ✅ 按鈕 -> 寫入 SSID & 密碼/Test-ok
            //            Button(action: {
            //               if !selectedSSID.isEmpty && !wifiPassword.isEmpty {
            //                   print("開始寫入 SSID & 密碼")
            //                   bluetoothManager.writeSSID("\(selectedSSID)")
            //                   DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // ✅ 等待 1 秒寫入密碼
            //                       bluetoothManager.writePassword("\(wifiPassword)")
            //                   }
            //               }
            //            }) {
            //               Text("設定 Wi-Fi")
            //                   .font(.body)
            //                   .frame(minWidth: 0, maxWidth: .infinity)
            //                   .padding()
            //                   .foregroundColor(.white)
            //                   .background(selectedSSID.isEmpty || wifiPassword.isEmpty ? Color.gray : Color.blue)
            //                   .cornerRadius(10)
            //            }
            //            .disabled(selectedSSID.isEmpty || wifiPassword.isEmpty)
            
            // ✅ 顯示設定狀態/Test-ok
            //            if let status = bluetoothManager.wifiSetupStatus {
            //               Text(status)
            //                   .font(.headline)
            //                   .foregroundColor(status.contains("成功") ? .green : .red)
            //                   .padding()
            //            }
            
            // 「開始搜索」按鈕
            if( bluetoothManager.wifiNetworks.isEmpty ) {
                Button(action: {
                    // 1. 重置藍牙與 Wi-Fi 資料
                    bluetoothManager.discoveredPeripherals.removeAll()  // 清空藍牙裝置
                    bluetoothManager.wifiNetworks.removeAll()           // 清空 Wi-Fi 網路
                    self.selectedDevice = nil        // ⬅️ 重置選擇的藍牙裝置
                    self.isRotating = false          // 重置旋轉動畫
                    self.isEmpty = false             // 隱藏「無資料」訊息
                    bluetoothManager.startScanning() // 啟動藍芽掃描
                    triggerHapticFeedback(model: .heavy) // 觸發震動
                    
                }) {
                    Text("開始搜尋")
                        .font(.body)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.g_green)
                        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: -2)
                        .contentShape(Rectangle()) // 讓整個區域可點擊
                }
                .cornerRadius(5)
            }
            
        }
        .padding()
    }
}

#Preview {
    BluetoothView(isPresented: .constant(true), selectedTab: .constant("藍牙"), isConnected: .constant(false))
}
