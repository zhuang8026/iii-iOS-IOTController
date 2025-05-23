//
//  UserLogin.swift
//  Sttptech_energy
//
//  Created by CHUANG CHIEH-HAN on 2025/5/13.
//
import SwiftUI

struct UserLogin: View {
    @EnvironmentObject var appStore: AppStore

    @State private var username: String = "sea.han@msa.hinet.net"
    @State private var password: String = "Enargy17885@"
    @State private var isPasswordVisible: Bool = false
    //    @State private var loginToken: String?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("登入")
                .font(.largeTitle)
                .bold()
            Text("\(version)")
                .font(.system(size: 12))
            
            // 帳號欄位
            TextField("帳號", text: $username)
                .padding()
                .frame(height: 60)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .autocapitalization(.none)
            
            // 密碼欄位 + 眼睛圖示
            ZStack(alignment: .trailing) {
                Group {
                    if isPasswordVisible {
                        TextField("密碼", text: $password)
                    } else {
                        SecureField("密碼", text: $password)
                    }
                }
                .padding()
                .frame(height: 60)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(username.isEmpty || password.isEmpty || isLoading)
            
            if isLoading {
                ProgressView()
            }
            
            if let token = appStore.userToken {
                Text("取得的 Token: \(token)")
                    .foregroundColor(.green)
                    .padding(.top)
            }
            
            if let error = errorMessage {
                Text("錯誤: \(error)")
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
        .padding()
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        appStore.userToken = nil
        
        guard let url = URL(string: "https://www.energy-active.org.tw/api/main/login") else {
            errorMessage = "無效的 URL"
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
                    errorMessage = "網路錯誤：\(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "沒有收到資料"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let code = json["code"] as? Int, code == 200,
                           let dataDict = json["data"] as? [String: Any],
                           let token = dataDict["token"] as? String {
                            appStore.userToken = token
                            UserDefaults.standard.set(token, forKey: "MQTTAccessToken") // 若你也想持久化
                        } else {
                            let message = json["message"] as? String ?? "未知錯誤"
                            errorMessage = "登入失敗：\(message)"
                        }
                    } else {
                        errorMessage = "資料格式錯誤"
                    }
                } catch {
                    errorMessage = "解析錯誤：\(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
