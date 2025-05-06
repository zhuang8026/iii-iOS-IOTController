//
//  WiFiManager.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/5/6.
//

import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class WiFiManager: NSObject {
    
    static let shared = WiFiManager() // 單例模式
    
    func connectToWiFi(ssid: String, password: String, isWEP: Bool = false, completion: @escaping (Bool, String) -> Void) {
        print("connectToWiFi:\(ssid),\(password)")
        
        // Step 1: 先移除舊設定，避免衝突
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)

        // Step 2: 加一點延遲後再建立新連線
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: isWEP)
            
            configuration.joinOnce = true // 保持連線
            configuration.lifeTimeInDays = 1 // iOS 16+
    
            NEHotspotConfigurationManager.shared.apply(configuration) { error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        let nsError = error as NSError
//                        completion(false, "Wi-Fi 連接失敗: \(nsError.localizedDescription) (Code: \(nsError.code))")
//                        print("Wi-Fi 連接失敗: \(nsError.localizedDescription) (Code: \(nsError.code))")
//                    } else {
//                        completion(true, "成功連接到 Wi-Fi: \(ssid)")
//                        print("成功連接到 Wi-Fi: \(ssid)")
//                    }
//                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    let currentSSID = self.currentWiFiSSID()
                    if let error = error {
                        completion(false, "Wi-Fi 連接失敗: \(error.localizedDescription)")
                    } else if currentSSID == ssid {
                        completion(true, "成功連接到 Wi-Fi: \(ssid)")
                    } else {
                        completion(false, "未連接到正確 Wi-Fi（當前 SSID: \(currentSSID ?? "未知")）")
                    }
                }
            }

//            NEHotspotConfigurationManager.shared.getConfiguredSSIDs() { ssids in
//                if ssids.contains(ssid) {
//                    print("配置中已存在 SSID: \(ssid)")
//                } else {
//                    print("SSID 尚未配置或配置失敗")
//                }
//            }

        }
    }
    
    func currentWiFiSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as NSArray? else { return nil }
        for interface in interfaces {
            guard
                let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary?,
                let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
            else {
                continue
            }
            return ssid
        }
        return nil
    }
    
}

