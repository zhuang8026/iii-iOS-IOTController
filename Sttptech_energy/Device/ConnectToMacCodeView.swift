
//
//  ConnectToMacCodeView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/4/11.
//
import SwiftUI

struct MacCodeInfo: Codable {
    let deviceMac: String
    let pwd: String
}

struct ConnectToMacCodeView: View {
    //    @EnvironmentObject var mqttManager: MQTTManager // 從環境取得 MQTTManager
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    @Binding var isPresented: Bool  // 綁定來控制顯示/隱藏
    @Binding var isConnected: Bool // MQTT是否已連線
    
    @State private var macLoading: Bool = false
    @State private var deviceMac: String = "" // DE:AD:BE:EF:00:01
    @State private var connectionMessage: String = ""
    @State private var showScanner: Bool = false // 開啟掃描模式
    //    @FocusState private var isFieldFocused: Bool  // 用來偵測鍵盤焦點
    
    
    var isFormValid: Bool {
        !deviceMac.isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("智能環控設定") // 「標題」
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
                            Text("Mac代碼")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            //                            Spacer()
                            //                            Image(systemName: "qrcode.viewfinder")
                            //                                .foregroundColor(.g_blue)
                            //                                .onTapGesture {
                            //                                    showScanner = true
                            //                                }
                        }
                        ZStack(alignment: .trailing) {
                            TextField("輸入Mac代碼", text: $deviceMac)
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
                        //                        .focused($isFieldFocused) // 設定焦點
                        
                        
                    }
                    .padding(.horizontal)
                    
                    // 送出按鈕
                    Button(action: connectToMac) {
                        Text("開始連接")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFormValid ? Color.g_green : Color.light_gray2) // 綠色(可按) / 灰色(禁用)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid) // 當 deviceMac 為空時，按鈕無法點擊
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            
            // 加載畫面（放在最上層）
            if macLoading {
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
            //            isFieldFocused = false  // 點擊畫面時取消鍵盤焦點
        }
        .fullScreenCover(isPresented: $showScanner) {
            QRCodeScannerView(
                onScan: { scanned in
                    if let data = scanned.data(using: .utf8),
                       let macInfo = try? JSONDecoder().decode(MacCodeInfo.self, from: data) {
                        self.deviceMac = macInfo.deviceMac
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
    
    // 連接 智能環控 的方法
    func connectToMac() {
        //        isFieldFocused = false  // 點擊畫面時取消鍵盤焦點
        macLoading = true
        connectionMessage = "嘗試連接 \(deviceMac)..."
        //        mqttManager.publishBindSmart(deviceMac: deviceMac) // 發布「智慧環控連接」發送指令
        MQTTManagerMiddle.shared.bindSmartDevice(mac: deviceMac)
        
        
        if (MQTTManagerMiddle.shared.isSmartBind) {
            print("環控狀態：\(MQTTManagerMiddle.shared.isSmartBind)，前往溫濕度view")
            macLoading = false // ✅ 綁定成功, 關閉加在動畫
            isConnected = true // ✅ 更新連線狀態,前往溫濕度
        } else {
            print("智慧環控綁定失敗")
            // 3秒後關閉 loading
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            //                macLoading = false
            //            }
        }
    }
}
