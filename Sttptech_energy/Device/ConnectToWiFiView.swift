
//
//  ConnectToWiFiView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/8.
//
import SwiftUI

struct WiFiInfo: Codable {
    let ssid: String
    let pwd: String
}

struct ConnectToWiFiView: View {
    @Binding var isPresented: Bool  // 綁定來控制顯示/隱藏
    @Binding var isConnected: Bool // 設備藍芽是否已連線

    @State private var wifiLoading: Bool = false
    @State private var ssid: String = ""
    @State private var password: String = ""
    @State private var connectionMessage: String = ""
    @State private var showScanner: Bool = false // 開啟掃描模式
    
    @State private var isPasswordVisible: Bool = false  // 🔥 用來切換密碼可見性
    @FocusState private var isSSIDFocused: Bool // ssid 指定焦點
    @FocusState private var isPasswordFocused: Bool // pwd 指定焦點
    @FocusState private var isFieldFocused: Bool  // 用來偵測鍵盤焦點
    
    
    var isFormValid: Bool {
        !ssid.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Wi-Fi裝置設定") // 「標題」
                        .font(.body)
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.forward") //「返回icon」
                        .foregroundColor(.g_blue)
                        .font(.system(size: 20))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPresented = false  // 退出畫面
                            }
                        }
                }
                
                Spacer()
                
                VStack(spacing: 18) {
                    // Wi-Fi名稱
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            Text("Wi-Fi名稱 (SSID)")
                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            Image(systemName: "qrcode.viewfinder")
//                                .foregroundColor(.g_blue)
//                                .onTapGesture {
//                                    showScanner = true
//                                }
                        }
                        ZStack(alignment: .trailing) {
                            TextField("輸入 Wi-Fi 名稱 (SSID)", text: $ssid)
                                .submitLabel(.next)  // ✅ 提示 SwiftUI 這是「下一個輸入框」
                            Image(systemName: "qrcode")
                                .foregroundColor(.g_blue)
                                .onTapGesture {
                                    showScanner = true
                                }
                        }
                        .padding()
                        .frame(height: 60)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.light_gray2))
                        .textInputAutocapitalization(.never) // ✅ 禁止自動大寫
                        .disableAutocorrection(true) // ✅ 禁止自動修正
                        .focused($isFieldFocused) // 設定焦點
                        
                      
                    }
                    .padding(.horizontal)
                    
                    // Wi-Fi密碼
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Wi-Fi密碼")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ZStack(alignment: .trailing) {
                            if isPasswordVisible {
                                TextField("輸入 Wi-Fi 密碼", text: $password)
                            } else {
                                SecureField("輸入 Wi-Fi 密碼", text: $password)
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.g_blue)
//                                    .padding(.trailing, 10)
                            }
                        }
                        .padding()
                        .frame(height: 60)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.light_gray2))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($isFieldFocused)
                    }
                    .padding(.horizontal)
                    
                    // 送出按鈕
                    Button(action: connectToWiFi) {
                        Text("連接 Wi-Fi")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFormValid ? Color.g_green : Color.light_gray2) // 綠色(可按) / 灰色(禁用)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid) // 當 ssid 或 password 為空時，按鈕無法點擊
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            
            // 加載畫面（放在最上層）
            if wifiLoading {
                ZStack {
                    Color.black.opacity(0.8) // 透明磨砂黑背景
                        .edgesIgnoringSafeArea(.all) // 覆蓋整個畫面
                    
                    VStack {
                        Loading(text: connectionMessage,color: Color.white)
                    }
                }
                .transition(.opacity) // 讓 Loading 畫面出現時有漸變動畫
            }
        }
        .onTapGesture {
            isFieldFocused = false  // 點擊畫面時取消鍵盤焦點
        }
        .fullScreenCover(isPresented: $showScanner) {
            QRCodeScannerView(
                onScan: { scanned in
                    print(scanned)
                    if let data = scanned.data(using: .utf8),
                       let wifi = try? JSONDecoder().decode(WiFiInfo.self, from: data) {
                        self.ssid = wifi.ssid
                        self.password = wifi.pwd
                    } else {
                        print("❌ 無法解析掃描內容")
                    }
                    self.showScanner = false
                },
                onCancel: {
                    self.showScanner = false
                }
            )
        }
    }
    
    // 連接 Wi-Fi 的方法
    func connectToWiFi() {
        isFieldFocused = false  // 點擊畫面時取消鍵盤焦點
        wifiLoading = true
        connectionMessage = "嘗試連接 \(ssid)..."
        WiFiManager.shared.connectToWiFi(ssid: ssid, password: password) { success, message in
            connectionMessage = message
            
            // 測試 - 非正常連接
            isConnected = true // ✅ 更新連線狀態

            // 3秒後關閉 loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                wifiLoading = false
            }
            
        }
    }
}
