//
//  TemperatureAPI.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation

extension APIService {
    // 去的資料
    func apiGetTemperatureInfo() async throws -> RoomData? {
        let endpoint = "/extractor/processing-values/room/\(roomID)/"
        return try await sendRequest(endpoint: endpoint, method: .GET, decodingType: RoomData.self)
    }

}
