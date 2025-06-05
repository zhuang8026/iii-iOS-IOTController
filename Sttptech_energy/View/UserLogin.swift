//
//  UserLogin.swift
//  Sttptech_energy
//
//  Created by CHUANG CHIEH-HAN on 2025/5/13.
//
import SwiftUI

struct UserLogin: View {
    @EnvironmentObject var appStore: AppStore
    
    //    @State private var username: String = "q0922604297@gmail.com" // sea.han@msa.hinet.net
    @State private var username: String = UserDefaults.standard.string(forKey: "RememberedEmail") ?? ""

    @State private var password: String = "Enargy17885@" // Enargy17885@

//    @State private var rememberEmail: Bool = false // 是否記住帳號
    @AppStorage("rememberEmail") private var rememberEmail: Bool = false // 是否記住帳號

    @State private var isPasswordVisible: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String?
    @State private var isAlert: Bool = false
    @State private var isLoading: Bool = false

    @State private var forgotEmail: String = ""
    @State private var isForgotPWD: Bool = false

    func login() {
        isLoading = true
        errorMessage = nil
        appStore.userToken = nil
        
        if rememberEmail {
            UserDefaults.standard.set(username, forKey: "RememberedEmail")
        } else {
            UserDefaults.standard.removeObject(forKey: "RememberedEmail")
        }
        
        guard let url = URL(string: "https://www.energy-active.org.tw/api/main/login") else {
            errorTitle = "錯誤提示"
            errorMessage = "無效的 URL"
            isAlert = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "userId=\(username)&userPwd=\(password)"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorTitle = "網路錯誤"
                    errorMessage = "\(error.localizedDescription)"
                    isAlert = true
                    return
                }
                
                guard let data = data else {
                    errorTitle = "錯誤提示"
                    errorMessage = "沒有收到資料"
                    isAlert = true
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if
                            let code = json["code"] as? Int, code == 200,
                            let dataDict = json["data"] as? [String: Any],
                            let token = dataDict["token"] as? String
                        {
                            isAlert = false
                            appStore.userToken = token
                            UserDefaults.standard.set(token, forKey: "MQTTAccessToken") // 若你也想持久化
                            
                            
                        } else {
                            let message = json["message"] as? String ?? "未知錯誤"
                            errorTitle = "登入失敗"
                            errorMessage = "\(message)"
                            isAlert = true
                        }
                    } else {
                        errorTitle = "錯誤提示"
                        errorMessage = "資料格式錯誤"
                        isAlert = true
                    }
                } catch {
                    errorTitle = "解析錯誤"
                    errorMessage = "\(error.localizedDescription)"
                    isAlert = true
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack() {
            // 背景圖片
            Image("ios_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                VStack(spacing: 5) {
                    Text("Welcome !")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.deep_green)
                    Text("居家能源管理服務")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.middle_green)
                }
                
                ZStack(alignment: .trailing) {
                    // 帳號欄位
                    TextField("Email address", text: $username)
                        .padding()
                        .frame(height: 60)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule()) // 半圓
                        .autocapitalization(.none)
                    
                    Button(action: {
                        rememberEmail.toggle()
                    }) {
                        Text("記住")
                            .font(.system(size: 16))
                        Image(systemName: rememberEmail ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(rememberEmail ? .middle_green : .gray)
                            .font(.system(size: 24))
                    }
                    .padding(.trailing, 14) // 左邊
//                    .padding(.leading, 14) // 右邊
                    
                    .accessibilityLabel("記住")
                }
                
                Group {
                    // 密碼欄位 + 眼睛圖示
                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .padding()
                        .frame(height: 60)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule()) // 半圓
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    // 登入按鈕
                    Button(action: {
                        login()
                    }) {
                        Text("登入")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                        //                    .background(Color.g_green)
                        //                    .cornerRadius(12)
                    }
                    .disabled(username.isEmpty || password.isEmpty || isLoading)
                    .background(username.isEmpty || password.isEmpty ? Color.light2_green.opacity(0.2) : Color.light2_green)
                    .clipShape(Capsule()) // 半圓
                    
                    Text("忘記密碼？")
                        .font(.system(size: 12))
                        .padding(.bottom, 20)
                        .onTapGesture {
                            isForgotPWD = true
                        }
                }
                .opacity(username.isEmpty ? 0 : 1) // 眼睛按鈕也透明
                .animation(.easeInOut(duration: 0.3), value: username)
                
                Text("\(version)")
                    .font(.system(size: 12))
                    .padding(.bottom, 20)
                
            }
            .padding()
            .frame(maxWidth: 350) // ✅ 限制最大寬度
            .onAppear {
                if rememberEmail {
                    username = UserDefaults.standard.string(forKey: "RememberedEmail") ?? ""
                }
            }
            .alert("\(errorTitle)", isPresented: $isAlert) {
                Button("確認", role: .none) {
                    withAnimation { isAlert = false }
                }
            } message: {
                if let error = errorMessage {
                    Text("\(error)")
                        .foregroundColor(.red)
                        .padding(.top)
                }
            }
            
            if isLoading {
                Color.light_green.opacity(0.85) // 透明磨砂黑背景
                    .edgesIgnoringSafeArea(.all) // 覆蓋整個畫面
                Loading(text: "登入中...",color: Color.g_blue)
                //                ProgressView() // 系統自帶loading
            }
        }
        .sheet(isPresented: $isForgotPWD) {
            VStack(spacing: 20) {
                Text("重設密碼")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.light2_green)

                TextField("請輸入 Email", text: $forgotEmail)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())  // 半圓
                    .autocapitalization(.none)
                    .padding(.horizontal)
    
                Button(action: {}) {
                    Text("送出")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
//                        .background(Color.middle_green)
                }
                .disabled(forgotEmail.isEmpty)
                .background(forgotEmail.isEmpty ? Color.light2_green.opacity(0.2) : Color.light2_green)
                .clipShape(Capsule()) // 半圓
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .presentationDetents([.fraction(0.33)]) // 限制高度為畫面 1/3
            .presentationDragIndicator(.visible) // 拖曳拉把手
        }
    }

}
