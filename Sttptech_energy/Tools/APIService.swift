//
//  APIService.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/5.
//
import Foundation

// MARK: - basic data
let website = "https://energyhub-dev.notiii.com/api/v2/energy-etl/iii/iot"
let roomID = "042dcafa-ef92-46b8-be51-a86d8c777a00"

// MARK: - API Service

@MainActor
class APIService: ObservableObject {
    
    // 通用的 API 請求函數
    func sendRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        payload: [String: Any]? = nil,
        decodingType: T.Type) async throws -> T? {
        let urlString = "\(website)\(endpoint)?access_token=000000"
        guard let url = URL(string: urlString) else {
            print("❌ 無效的 URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let payload = payload {
            // JSON 轉換
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
}

