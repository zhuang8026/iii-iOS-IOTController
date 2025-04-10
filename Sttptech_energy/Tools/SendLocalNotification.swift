//
//  AnimationModels.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/18.
//

import SwiftUI

// 發送本地推播通知（Local Notification）
func sendLocalNotification(title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    content.badge = 1 // 顯示在應用圖標上的數字
    
//    未完成
//    content.userInfo = [
//         "selectedTab": tab,
//         "mutable-content": "1",  // 內容是可以動態改變
//         "content-available": "1" // 不會直接顯示通知，而是會在後台觸發應用的背景處理。
//     ]

    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: nil // 立即觸發
    )
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("❌ 發送通知失敗：\(error.localizedDescription)")
        } else {
            print("✅ 已發送本地推播通知")
        }
    }
}
