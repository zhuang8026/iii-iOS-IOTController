//
//  APIModels.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

// ✅ API 回應模型
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

struct TemperatureData: Decodable {
    let temperature_r: String
    let humidity_r: String
    let update_time: String
}

struct ACData: Decodable {
    let power_rw: String
    let op_mode_rw: String
    let temperature_cfg_rw: String
    let fan_level_rw: String
    let outdoor_unit_power_watt_r: String?
    let comfortable_rw: String?
    let update_time: String
}

struct DehumidifierData: Decodable {
    let power_rw: String
    let op_mode_rw: String
    let humidity_cfg_rw: String
    let fan_level_rw: String?
    let op_power_watt_r: String?
    let dehumidifier_level_rw: String
    let update_time: String
}

struct RoomData: Decodable {
    let roomid: String
    let sensor: TemperatureData
    let ac: ACData
    let dehumidifier: DehumidifierData
}
