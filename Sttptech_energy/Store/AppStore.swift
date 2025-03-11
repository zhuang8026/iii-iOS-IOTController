//
//  Store.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/27.
//

import SwiftUI

// ✅ 1. 創建全域狀態 Store
class AppStore: ObservableObject {
    @Published var showPopup: Bool = false // 提示窗顯示 開關
    @Published var isAIControl: Bool = false // AI決策顯示 開關
    @Published var title: String = "TITLE"
    @Published var message: String  = "MESSAGE"
}
