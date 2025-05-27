//
//  StructModel.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/12.
//

import Foundation

// 家電讀寫能力結構
//struct CapabilityData {
//    let values: [String] // ["read", "auto", "low", "medium", "high", "strong", "max", "0"~"35","-128"~"127"]
//}

// 每個裝置的能力對應資料
struct ApplianceCapabilitiesResponse: Codable {
    let edgeBind: Bool
    let capabilities: [String: [String: [String]]] // ["read", "auto", "low", "medium", "high", "strong", "max", "0"~"35","-128"~"127"]
    let availables: [String]

    enum CodingKeys: String, CodingKey {
        case edgeBind = "edge_bind"
        case capabilities
        case availables
    }
}

// 家電數據結構
struct electricData: Equatable {
    var value: String
    var updated: String
}


struct DateUtils {
    /// 將 ISO8601 字串轉為 Date（台灣時區）
    static func parseISO8601DateInTaiwanTimezone(from string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 8 * 3600) // 台灣時區 +8
        return formatter.date(from: string)
    }
}
