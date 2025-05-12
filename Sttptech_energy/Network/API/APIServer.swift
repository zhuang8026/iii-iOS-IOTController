//
//  TemperatureAPI.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation


extension APIService {
    // MARK: - Step1 -  請求 Dongle 掃描並取得 WiFi 列表
    func apiGetWiFiScanApInfo(useMock: Bool = false) async throws -> ApData {
        if useMock {
            return try loadJSON(fileName: "getwifiScanAp_step1", as: ScanApListResponse.self).data
        }
        let response = try await fetchAPI(endpoint: "api/config/wifi/scanAp", decodingType: ScanApListResponse.self)
        return response.data
    }
    
    // MARK: - Step2 - 請求 Dongle 寫入、儲存 WiFi 連線設定
    func apiGetWiFiSetting(ssid: String, password: String, security: String, useMock: Bool = false) async throws -> WiFiConfigResponse {
        if useMock {
            return try loadJSON(fileName: "getwifiSetting_step2", as: WiFiConfigResponse.self)
        }
        let response = try await fetchAPI(endpoint: "api/config/wifi/set?param=\(ssid)&attr=\(password)&option=psk2", decodingType: WiFiConfigResponse.self)
        return response
    }
    
    // MARK: - Step3 - 請求 Dongle 開始連線到家用 WiFi
    func apiGetWiFiConnect(useMock: Bool = false) async throws -> WiFiConnectResponse {
        if useMock {
            return try loadJSON(fileName: "getwifiConnect_step3", as: WiFiConnectResponse.self)
        }
        let response = try await fetchAPI(endpoint: "api/config/wifi/connect", decodingType: WiFiConnectResponse.self)
        return response
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


