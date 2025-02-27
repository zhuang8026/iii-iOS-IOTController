//
//  Sttptech_energyApp.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/14.
//

import SwiftUI

@main
struct Sttptech_energyApp: App {
    @StateObject private var appStore = AppStore()  // 全域狀態管理

    var body: some Scene {
        WindowGroup {
            ContentView()
                .foregroundColor(.g_blue) // 全局文字顏色為藍色
                .environmentObject(appStore)  // 傳遞全域狀態
//                .tint(.g_blue) // 全局主題顏色，包括文字、按鈕和鏈接等
        }
    }
}
