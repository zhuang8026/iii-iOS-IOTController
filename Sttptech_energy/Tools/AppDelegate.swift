//
//  AppDelegate.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/4/10.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // App 啟動時
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // 通知中心設定
        UNUserNotificationCenter.current().delegate = self
        
        // 請求推播權限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ 使用者同意推播")
            } else {
                print("❌ 使用者不同意推播")
            }
        }
        
        // 向 APNs 註冊
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }

        return true
    }
    
    // 成功註冊推播，取得 device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        print("📱 Device Token: \(token)")
        // 你可以把 token 傳到後端儲存
        MQTTManagerMiddle.shared.setDeviceToken(deviceToken: token)
    }

    // 推播註冊失敗
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ 無法註冊 APNs: \(error.localizedDescription)")
    }

    // MARK: - 推播收到時（前景）
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
            print("✅ 前景收到推播資料: \(userInfo)")
        // 嘗試解析 notify 並顯示文字
//        if let notify = userInfo["notify"] as? [String: Any] {
//            let message = returnAIDecisionText(from: notify)
//            showAIDecisionAlert(message: message)
//        }

        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - 顯示 AI 建議的彈窗
//    func showAIDecisionAlert(message: String) {
//        DispatchQueue.main.async {
//            if let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
//                let alert = UIAlertController(title: "AI 決策建議", message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "了解", style: .default, handler: nil))
//                rootVC.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
    
}
