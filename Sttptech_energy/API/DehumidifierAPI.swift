//
//  TemperatureAPI.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation

extension APIService {
    // 去的資料
//    func apiGetDehumidifierInfo() async throws -> RoomData? {
//        let endpoint = "/extractor/processing-values/room/\(roomID)/"
//        return await sendRequest(endpoint: endpoint, method: .GET, decodingType: RoomData.self)
//    }
    func apiGetDehumidifierInfo() async throws -> RoomData? {
        let endpoint = "/extractor/processing-values/room/\(roomID)/"
        return try await sendRequest(endpoint: endpoint, method: .GET, decodingType: RoomData.self)
    }
    
    func apiPostSettingDehumidifier(payload: [String: Any]) async throws -> ApiResponse? {
        let endpoint = "/loader/rooms/\(roomID)/script"
        return try await sendRequest(endpoint: endpoint, method: .POST, payload: payload, decodingType: ApiResponse.self)
    }

}


