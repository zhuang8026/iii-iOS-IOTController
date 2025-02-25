//
//  WiFiListView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/18.
//

import SwiftUI

struct WiFiListView: View {
    @ObservedObject var bluetoothManager: BluetoothManager // 父層傳入
    @Binding var selectedSSID: String // 父層管理選中的 SSID
    @Binding var password: String // 父層管理選中的 Wi-Fi 密碼
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    @State private var showPasswordSheet: Bool = false // 彈窗開關
//    @State private var password: String = "" // 密碼
    
    var body: some View {
        VStack(alignment: .leading) {
            LazyVStack(spacing: 10) {
                ForEach(bluetoothManager.wifiNetworks) { wifi in
                    Button(action: {
                        selectedSSID = wifi.ssid // ✅ 點選 SSID 後儲存
                        print("SSID: \(wifi.ssid)")
                        if selectedSSID == wifi.ssid {
                            showPasswordSheet.toggle() // 如果是同一個 Wi-Fi，切換顯示
                        } else {
                            selectedSSID = wifi.ssid // 更新選中的 SSID
                            password = "" // 清空密碼
                            showPasswordSheet = true // 彈出輸入框
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(wifi.ssid)")
                                    .font(.body)
                                    .foregroundColor(Color.g_blue)
//                                Text("RSSI: \(wifi.rssi) dBm")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                                Text("加密方式: \(wifi.enc)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image("wifi") // 未選擇
                        }
                        .padding()
                        .background(selectedSSID == wifi.ssid ? Color.g_green.opacity(0.2) : Color.light_gray)
                        .cornerRadius(5)
                    }
                }
            }
        }
        // 🚀 Wi-Fi 密碼輸入彈窗
        .sheet(isPresented: $showPasswordSheet, onDismiss: {
            password = "" // ✅ 關閉彈窗並清空密碼
        }) {
            PasswordInputDialog(
                bluetoothManager: bluetoothManager,
                selectedSSID: $selectedSSID,
                password: $password,
                isConnected: $isConnected
            ) {
                showPasswordSheet = false // 點擊送出後關閉
            }
        }
    }


    
}

