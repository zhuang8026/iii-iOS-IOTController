//
//  WiFiManager.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/7.
//

import NetworkExtension

class WiFiManager: NSObject {
    
    static let shared = WiFiManager() // 單例模式
    
    func connectToWiFi(ssid: String, password: String, isWEP: Bool = false, completion: @escaping (Bool, String) -> Void) {
        let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: isWEP)
        
        configuration.joinOnce = true // 保持連線

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NEHotspotConfigurationManager.shared.apply(configuration) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        let nsError = error as NSError
                        completion(false, "Wi-Fi 連接失敗: \(nsError.localizedDescription) (Code: \(nsError.code))")
                        print("Wi-Fi 連接失敗: \(nsError.localizedDescription) (Code: \(nsError.code))")
                    } else {
                        completion(true, "成功連接到 Wi-Fi: \(ssid)")
                        print("成功連接到 Wi-Fi: \(ssid)")
                    }
                }
            }
        }
    }
}

