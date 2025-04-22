//
//  TemperatureAPI.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation


extension APIService {
    // MARK: - GET
    func apiGetWiFiScanApInfo(useMock: Bool = false) async throws -> ApData {
        //MARK: - MOCK API
        if useMock {
            print("🚧 使用 Mock Data 中...")
            
            // 從專案中讀取 getwifiscanAp.json 檔案
            guard let url = Bundle.main.url(forResource: "getwifiscanAp", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                throw NSError(domain: "APIServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "載入 Mock 資料失敗"])
            }
            
            let decoder = JSONDecoder()
            do {
                let mockResponse = try decoder.decode(ScanApList.self, from: data)
                return mockResponse.data
            } catch {
                throw NSError(domain: "APIServiceError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Mock 資料解析失敗：\(error.localizedDescription)"])
            }
        }
        
        //MARK: - Prod API
        let endpoint = "api/config/wifi/scanAp"
        guard let response: ScanApList = try await sendRequest(endpoint: endpoint, method: .GET, decodingType: ScanApList.self) else {
            throw NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "無法獲取設備資料"])
        }
        
        print("📡 API WiFiScanApInfo -> \(response)")
        return response.data
    }
    
    // MARK: - POST
    //    func apiPostSettingAIController(payload: RoomData) async throws -> ApiResponse? {
    //        guard let payloadDict = payload.toDictionary() else {
    //            throw NSError(domain: "EncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode payload"])
    //        }
    //
    //        print("apiPost Setting AIController -> \(payloadDict)")
    //
    //        let endpoint = "/loader/rooms/\(roomID)/script"
    //        return try await sendRequest(endpoint: endpoint, method: .POST, payload: payloadDict, decodingType: ApiResponse.self)
    //    }
}


