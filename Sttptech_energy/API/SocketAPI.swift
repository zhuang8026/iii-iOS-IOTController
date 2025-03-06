//
//  socket_api.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/3/6.
//



// 透過 extension 將特定 API 端點相關方法移至另一個檔案
extension APIService {
    // 送出資料
    func apiPostSettingSocket(payload: [String: Any]) async -> ApiResponse? {
        let endpoint = "/loader/rooms/\(roomID)/script"
        return await sendRequest(endpoint: endpoint, method: .POST, payload: payload, decodingType: ApiResponse.self)
    }
}

