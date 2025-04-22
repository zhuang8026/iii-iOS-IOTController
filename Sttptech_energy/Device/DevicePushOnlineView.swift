//
//  BluetoothView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/8.
//

import SwiftUI
import CoreBluetooth

let wifiList = ["HH42CV_19D7", "HomeWiFi", "Cafe_123"]

struct DevicePushOnlineView: View {
    @Binding var selectedTab: String // 標題名稱
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    @State private  var wifiList: [String] = []

    //    @State private var isRotating = false // loading 旋轉動畫控制
    @State private var showPasswordSheet: Bool = false // 彈窗開關
    
    @State private var selectedSSID: String = "HH42CV_19D7"
    @State private var wifiPassword: String = ""
    @State private var isEmpty: Bool = false
    
    var onCancel: () -> Void  // 用來關閉畫面的 callback
    
    func fetchWiFiList() {
        Task {
            do {
                let data = try await apiService.apiGetWiFiScanApInfo(useMock: true)
                print("fetchWiFiList: \(data)")
//                await MainActor.run {
//                    self.wifiList = data.apList.map { $0.ssid }
//                }
            } catch {
//                await MainActor.run {
//                    self.errorMessage = error.localizedDescription
//                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(selectedTab)設備設定") // 「標題」
                    .font(.body)
                Spacer()
                Button(action: {
                    onCancel()  // 👉 呼叫上層的取消關閉畫面
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.forward") //「返回icon」
                        .foregroundColor(.g_blue)
                        .font(.system(size: 20)) // 调整图标大小
                }
            }
            
            //            if (bluetoothManager.discoveredPeripherals.isEmpty) { // 空藍芽資料
            //                VStack {
            //                    Spacer()
            //                    EmptyData()
            //                    Spacer()
            //                }
            //            } else if (bluetoothManager.isScanning) { // 掃描藍芽中
            //                VStack {
            //                    Spacer()
            //                    Loading()
            //                    Spacer()
            //                }
            //            } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // 顯示選擇的設備
                    Button(action: {print("顯示選擇的設備")}) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("設備名稱")
                                    .font(.headline)
                                    .foregroundColor(Color.g_blue) // 設備名稱
                                Spacer()
                                Text("0987654321-POIUYTREWQ-LKJHGFDSA")
                                    .font(.subheadline)
                                    .foregroundColor(Color.heavy_gray) // 設備 UUID
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
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
                    if isEmpty {
                        HStack {
                            Spacer()
                            EmptyData(text: "暫無可用 Wi-Fi")
                            Spacer()
                        }
                    } else {
                        // Wi-Fi列表
                        VStack(alignment: .leading) {
                            LazyVStack(spacing: 10) {
                                ForEach(wifiList, id: \.self) { wifi in
                                    Button(action: {
                                        // password = "" // 清空密碼
                                        showPasswordSheet = true // 彈出輸入框
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(wifi)
                                                    .font(.body)
                                                    .foregroundColor(Color.g_blue)
                                            }
                                            Spacer()
                                            Image("wifi") // 未選擇
                                        }
                                        .padding()
                                        .background(Color.light_gray)
                                        .cornerRadius(5)
                                    }
                                }
                            }
                        }
                        // 🚀 Wi-Fi 密碼輸入彈窗
                        .sheet(isPresented: $showPasswordSheet, onDismiss: {
                            wifiPassword = "" // ✅ 關閉彈窗並清空密碼
                        }) {
                            WiFiPasswordInputDialog(
                                selectedSSID: $selectedSSID,
                                password: $wifiPassword,
                                isConnected: $isConnected
                            ) {
                                showPasswordSheet = false // 點擊送出後關閉
                            }
                        }
                        
                        //                            HStack {
                        //                                Spacer()
                        //                                Loading(text: "尋找 Wi-Fi 中")
                        //                                Spacer()
                        //                            }
                        //                            .onAppear {
                        //                                // 10秒後檢查 Wi-Fi 列表是否還是空的
                        //                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        //                                    isEmpty = true
                        //                                }
                        //                            }
                    }
                }
            }
            .background(Color.clear) // 設定整個 `ScrollView` 背景
            //            }
            
            // 「開始搜索」按鈕
            Button(action: {
                // 1. 重置藍牙與 Wi-Fi 資料
                self.isEmpty = false             // 隱藏「無資料」訊息
                fetchWiFiList()
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
        .padding()
    }
}

