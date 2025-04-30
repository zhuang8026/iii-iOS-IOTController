//
//  APIModels.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

// MARK: -API 回應模型
struct ApiResponse: Codable {
    let success: Bool
    let originalData: OriginalData
    
    enum CodingKeys: String, CodingKey {
        case success
        case originalData = "original_data"
    }
}

struct OriginalData: Codable {
    let code: Int
    let msg: String
    let errMsgList: [String]?
    let responseTime: String
    let lang: String
    let resultData: Bool
    let success: Bool
}

// MARK: - Step1 -  請求 Dongle 掃描並取得 WiFi 列表
struct ScanApListResponse: Codable {
    let status: String
    let data: ApData
}

struct ApData: Codable {
    let count: Int
    let ap_list: [ApInfo]
}

struct ApInfo: Codable {
    let channel, ssid, bssid, security, signal, mode: String

    var id: String { bssid } // ✅ 讓 BSSID 當作唯一識別
}

// MARK: - Step2 - 請求 Dongle 寫入、儲存 WiFi 連線設定
struct WiFiConfigResponse: Codable {
    let status: String
    let err: APIError?

      struct APIError: Codable {
          let code: String
          let msg: String
      }
}


// MARK: - Step3 - 請求 Dongle 開始連線到家用 WiFi
struct WiFiConnectResponse: Codable {
    let status: String
    let err: APIError?

      struct APIError: Codable {
          let code: String
          let msg: String
      }
}
