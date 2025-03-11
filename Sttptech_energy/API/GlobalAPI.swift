//
//  TemperatureAPI.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation


extension APIService {
    // MARK: - 取得設備全部資料
    func apiGetAIControllerInfo() async throws -> RoomData {
        let endpoint = "/extractor/processing-values/room/\(roomID)/"
        
        guard let response: RoomData = try await sendRequest(endpoint: endpoint, method: .GET, decodingType: RoomData.self) else {
            throw NSError(domain: "APIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "無法獲取設備資料"])
        }
        
        print("apiGet AIControllerInfo -> \(response)")
        
        return RoomData(
            roomid: response.roomid,
            sensor: response.sensor,
            ac: response.ac,
            dehumidifier: response.dehumidifier
//            socket: response.socket
        ) // ✅ 傳出AI決策需要的資料
    }

    // MARK: - 送出全部資料（啟動AI決策）
    func apiPostSettingAIController(payload: RoomData) async throws -> ApiResponse? {
        guard let payloadDict = payload.toDictionary() else {
            throw NSError(domain: "EncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode payload"])
        }
        
        print("apiPost Setting AIController -> \(payloadDict)")
        
        let endpoint = "/loader/rooms/\(roomID)/script"
        return try await sendRequest(endpoint: endpoint, method: .POST, payload: payloadDict, decodingType: ApiResponse.self)
    }
}


