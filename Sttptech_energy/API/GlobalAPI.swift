//
//  TemperatureAPI.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//

import Foundation

extension APIService {
    func apiPostSettingAIController(payload: [String: Any]) async throws -> ApiResponse? {
        let endpoint = "/loader/rooms/\(roomID)/script"
        return try await sendRequest(endpoint: endpoint, method: .POST, payload: payload, decodingType: ApiResponse.self)
    }

}


