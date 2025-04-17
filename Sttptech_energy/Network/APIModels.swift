//
//  APIModels.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation

// MARK: - HTTP 方法 Enum
enum HTTPMethod: String {
    case GET
    case POST
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

// MARK: -API 送出模型
struct TemperatureData: Codable {
    let temperature_r: String
    let humidity_r: String
    let update_time: String
}

struct ACData: Codable {
    var power_rw: String
    let op_mode_rw: String
    var temperature_cfg_rw: String
    let fan_level_rw: String
    let outdoor_unit_power_watt_r: String?
    let comfortable_rw: String?
    let update_time: String
}

struct DehumidifierData: Codable {
    var power_rw: String
    let op_mode_rw: String
    var humidity_cfg_rw: String
    let fan_level_rw: String?
    let op_power_watt_r: String?
    let dehumidifier_level_rw: String
    let update_time: String
}

struct SocketData: Codable {
    let power_w: String
}

struct RoomData: Codable {
    let roomid: String
    let sensor: TemperatureData
    var ac: ACData
    var dehumidifier: DehumidifierData
    var socket: [String: String]? // ✅ 新增 socket 欄位
}

// MARK: - 擴展 Encodable 轉換為 Dictionary
extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
    }
}

