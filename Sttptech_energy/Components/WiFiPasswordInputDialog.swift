//
//  PasswordInputView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/18.
//

import SwiftUI

struct AlertInfo {
    var status: Bool
    var title: String
    var content: String
    var btn: String
}

struct WiFiPasswordInputDialog: View {
    @StateObject private var apiService = APIService() // ✅ 讓 SwiftUI 監聽 API 回應
    
    @Binding var selectedSSID: String  // 父層傳入 (單向傳遞，不會更改)
    @Binding var password: String  // 父層傳入 (密碼需要雙向綁定)
    @Binding var security: String  // 父層傳入 (密碼需要雙向綁定)
    
    @Binding var isConnected: Bool // 父層傳入 (設備藍芽是否已連線)
    @State private var isWiFiLoading: Bool = false // 送出Wifi密碼狀態
    
    @State private var showAlert: Bool = false // 控制 Alert
    @State private var alertInfo = AlertInfo(status: false, title: "", content: "", btn: "")
    
    var onSend: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool  // 追蹤輸入框焦點
    
    
    func sendWiFiConfig() async {
        guard !selectedSSID.isEmpty, !password.isEmpty, !security.isEmpty else {
            print("❌ 請填寫完整資訊")
            isWiFiLoading = false
            return
        }
        
        print("✅ 開始寫入 Wi-Fi -> SSID: \(selectedSSID), 密碼: \(password), 加密: \(security)")
        
        do {
            let response = try await apiService.apiGetWiFiSetting(
                ssid: selectedSSID,
                password: password,
                security: security,
                useMock: true
            )
            print("✅ 寫入成功，回傳：\(response)")
            
            if response.status.lowercased() == "ok" {
                print("✅ Wi-Fi 設定成功")
                await MainActor.run {
                    alertInfo = AlertInfo(
                        status: true,
                        title: "Wi-Fi 設定完成",
                        content: "請點選確認進入主畫面。",
                        btn: "確認"
                    )
                    showAlert = true // 👉 彈出 alert
                }
            } else {
                print("❌ Wi-Fi 設定失敗")
                await MainActor.run {
                    alertInfo = AlertInfo(
                        status: false, // 連結失敗
                        title: "Wi-Fi 設定失敗",
                        content: "請確認密碼與 Wi-Fi 設定後重新送出。",
                        btn: "重新嘗試"
                    )
                    showAlert = true // 👉 彈出 alert
                }
            }
            
            
            
        } catch {
            await MainActor.run {
                isWiFiLoading = false
            }
            print("❌ 寫入失敗：\(error.localizedDescription)")
        }
    }
    
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
                        isWiFiLoading = true // 開始送出Wi-Fi密碼
                        Task {
                            await sendWiFiConfig()
                        }
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertInfo.title),
                message: Text(alertInfo.content),
                dismissButton: .default(Text(alertInfo.btn), action: {
                    if alertInfo.status {
                        isConnected = true
                        isWiFiLoading = false
                        onSend()
                    } else {
                        isWiFiLoading = false
                    }
                })
            )
        }
    }
}
