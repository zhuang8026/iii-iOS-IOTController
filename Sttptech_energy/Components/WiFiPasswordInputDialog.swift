//
//  PasswordInputView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/18.
//

import SwiftUI

struct WiFiPasswordInputDialog: View {
    //    @ObservedObject var bluetoothManager: BluetoothManager // 父層傳入
    
    @Binding var selectedSSID: String  // 父層傳入 (單向傳遞，不會更改)
    @Binding var password: String  // 父層傳入 (密碼需要雙向綁定)
    @Binding var isConnected: Bool // 父層傳入 (設備藍芽是否已連線)
    @State private var isWiFiLoading: Bool = false // 送出Wifi密碼狀態
    
    var onSend: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool  // 追蹤輸入框焦點
    
    var body: some View {
        VStack {
            Text(selectedSSID)
                .font(.title3)
                .bold()
                .padding(.top, 5)
            if (isWiFiLoading) {
                VStack {
                    Spacer()
                    Loading(text: "Wi-Fi連線中")
                    Spacer()
                }
            } else {
                HStack {
                    // 🔐 密碼輸入框
                    TextField("請輸入 Wi-Fi 密碼", text: $password)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .focused($isTextFieldFocused)
                    
                    // 📩 送出按鈕
                    Button(action: {
                        print("連接 \(selectedSSID)，密碼：\(password)")
                        
                        isWiFiLoading = true // 開始送出Wi-Fi密碼
                        //                        if !selectedSSID.isEmpty && !password.isEmpty {
                        //                            print("✅ 開始寫入Wi-Fi-> SSID/\(selectedSSID)")
                        //                            bluetoothManager.writeSSID("\(selectedSSID)") // ✅ 開始寫入 SSID
                        //
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // ✅ 等待 3 秒寫入密碼
                            print("✅ 開始寫入Wi-Fi-> 密碼/\(password)")
                            //                                bluetoothManager.writePassword("\(password)")
                            //
                            //                                isConnected = true // ✅ 更新連線狀態
                            isWiFiLoading = false // Wi-Fi密碼已成功送出（Wi-Fi密碼是否正確還不知道）
                            onSend() // 關閉子視窗
                        }
                        //                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(password.isEmpty ? Color.light_gray: Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(selectedSSID.isEmpty || password.isEmpty)
                    
                    // ✅ 顯示設定狀態/failed/欄位不會回傳資料
                    //                if let status = bluetoothManager.wifiSetupStatus {
                    //                   Text("")
                    //                       .font(.headline)
                    //                       .foregroundColor(status.contains("成功") ? .green : .red)
                    //                       .padding()
                    //                       .onAppear {
                    //                           print("WiFi 設定狀態：\(status)")
                    //                       }
                    //                }
                    
                }
                .padding()
            } // if end
        }
        .padding()
        .presentationDetents([.height(200.0), .height(200.0)]) // 固定高度
        //        .presentationDetents([.height(200), .medium, .large]) // 高度最小200，超過 200 自適應
        .presentationDragIndicator(.visible) // 顯示拖曳指示條
    }
}
