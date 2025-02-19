//
//  HeaderView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/20.
//

import SwiftUI

/// 頂部標題視圖
struct HeaderName: View {
    @Binding var selectedTab: String // 標題名稱
    @Binding var status: Bool // 是否要顯示返回（false -> back, true -> show title）
    @State private var isAIControl: Bool = false
    
    var body: some View {
        HStack {
            if status {
                Image("arrowLeft") // 改成返回按鈕
                    .font(.system(size: 20))
                Spacer()
                if (isAIControl) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("AI決策執行中")
//                            .font(.body)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .frame(height: 30.0)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .background(Color.warning)
                    .cornerRadius(100.0)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                   
                } else {
                    Text("\(selectedTab)設定")
                    .font(.body)
                }
                Spacer()
                Image(systemName: "trash") // 垃圾桶
                    .foregroundColor(Color.blue) // 確保顏色存在
                    .font(.system(size: 20)) // 調整圖示大小
                    .onTapGesture {
                        status = false // ✅ 點擊後切換 status
                    }
            } else {
                Image("arrowLeft") // 改成返回按鈕
                    .font(.system(size: 20))

                Spacer() // 推動其他內容到右側
            }
        }
    }
}
