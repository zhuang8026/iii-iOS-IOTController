
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
    @Binding var selectedTab: String // 標題名稱
    @Binding var isConnected: Bool // 設備藍芽是否已連線
    
    @State private var wifiLoading: Bool = false // 連結Wi-Fi狀態
    @State private var startConnectDevice: Bool = false // 是否開始連結設備
    @State private var ssid: String = "HH42CV_19D7"
    @State private var password: String = "10009447"
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
        NavigationStack {
            
            // 輸入帳號 & 密碼
            ZStack {
                VStack {
                    // header
                    HStack {
                        Text("\(selectedTab)連接設定") // 「標題」
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
                    
                    // Wi-Fi 帳號密碼設定/送出
                    VStack(spacing: 18) {
                        // Wi-Fi名稱
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                Text("Wi-Fi名稱")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                //                            Spacer()
                                //                            Image(systemName: "qrcode.viewfinder")
                                //                                .foregroundColor(.g_blue)
                                //                                .onTapGesture {
                                //                                    showScanner = true
                                //                                }
                            }
                            ZStack(alignment: .trailing) {
                                TextField("請輸入Wi-Fi名稱 (SSID)", text: $ssid)
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
                            Text("設備Wi-Fi密碼")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ZStack(alignment: .trailing) {
                                if isPasswordVisible {
                                    TextField("請輸入Wi-Fi密碼", text: $password)
                                } else {
                                    SecureField("請輸入Wi-Fi密碼", text: $password)
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
                        Button(action: connectToDeviceWiFi) {
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
                // loading - 加載畫面（放在最上層）
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
            .background(Color.light_green.opacity(1))
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
            .fullScreenCover(isPresented: $startConnectDevice) {
                DevicePushOnlineView(
                    selectedTab: $selectedTab,
                    isConnected: $isConnected,
                    onCancel: {
                        self.startConnectDevice = false
                    }
                )
                    .background(Color.light_green.opacity(1))
                   
            }
        }
        
    }
    
    // 連接 Wi-Fi 的方法
    func connectToDeviceWiFi() {
        isFieldFocused = false  // 點擊畫面時取消鍵盤焦點
        wifiLoading = true
        connectionMessage = "嘗試連接 \(ssid)..."
        WiFiManager.shared.connectToWiFi(ssid: ssid, password: password) { success, message in
            connectionMessage = message
            
            print("Wi-Fi conncet status: \(success)")
            
            if(success) {
                // ✅ 更新連線狀態 -> 去註冊設備Wi-Fi上線頁面
                startConnectDevice = true
                
                // ✅ 關閉 loading 並進入下一畫面
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    wifiLoading = false
                }
            } else {
                // ❌ 失敗時，只關閉 loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    wifiLoading = false
                }
            }
        }
    }
}
