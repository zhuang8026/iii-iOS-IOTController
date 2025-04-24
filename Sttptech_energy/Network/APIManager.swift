//
//  APIService.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/4/22.
//

import Foundation

// MARK: - basic data
let website = "https://192.168.30.1/"
let authToken = "YWRtaW46MTIzNDU2Nw==" // base64("admin:1234567")

// MARK: - API Service
@MainActor
class APIService: ObservableObject {
    
    func sendRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        payload: [String: Any]? = nil,
        decodingType: T.Type) async throws -> T? {

        let urlString = "\(website)\(endpoint)"
        guard let url = URL(string: urlString) else {
            print("❌ 無效的 URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 加入基本認證 Header
        request.setValue("Basic \(authToken)", forHTTPHeaderField: "Authorization")
        
        // 加入常見 Header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 處理 POST/PUT 輸入資料
        if let payload = payload {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                print("❌ JSON 序列化失敗")
                return nil
            }
            request.httpBody = jsonData
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    do {
                        return try decoder.decode(T.self, from: data)
                    } catch {
                        print("⚠️ JSON 解析失敗，回應內容: \(String(data: data, encoding: .utf8) ?? "無法轉換為字串")")
                    }
                } else {
                    print("❌ API 失敗，狀態碼: \(httpResponse.statusCode)")
                    print("❌ API 回應: \(String(data: data, encoding: .utf8) ?? "無法讀取回應")")
                }
            }
        } catch {
            print("❌ API 呼叫錯誤: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func loadJSON<T: Decodable>(
        fileName: String,
        fileExtension: String = "json",
        as type: T.Type
    ) throws -> T {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension),
              let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "APIServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "載入 Mock 資料失敗"])
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NSError(domain: "APIServiceError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Mock 資料解析失敗：\(error.localizedDescription)"])
        }
    }

    func fetchAPI<T: Decodable>(
        endpoint: String,
        decodingType: T.Type
    ) async throws -> T {
        guard let response: T = try await sendRequest(endpoint: endpoint, method: .GET, decodingType: decodingType) else {
            throw NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "API 請求失敗"])
        }
        return response
    }
}

