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
    }

    // 推播註冊失敗
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ 無法註冊 APNs: \(error.localizedDescription)")
    }

    // 前景收到通知時處理方式
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
