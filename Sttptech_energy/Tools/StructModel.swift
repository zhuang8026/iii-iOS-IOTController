//
//  StructModel.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/12.
//

import Foundation

/// 家電數據結構
//struct ApplianceData: Codable {
//    let value: String
//    let updated: String
//}

/// 家電數據結構
struct ApplianceData: Equatable {
    var value: String
    var updated: String
}
