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

// MARK: - Wi-Fi 資料結構
struct ScanApList: Codable {
    let status: String
    let data: ApData
}

struct ApData: Codable {
    let count: Int
    let ap_list: [ApInfo]
}

struct ApInfo: Codable {
    let channel: String
    let ssid: String
    let bssid: String
    let security: String
    let signal: String
    let mode: String
}
