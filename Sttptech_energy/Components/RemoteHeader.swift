//
//  RemoteHeader.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/19.
//

import SwiftUI

struct RemoteHeader: View {
    var body: some View {
        HStack {
            Image("remote-control")
            Text("是誰搶走我的遙控器")
            Spacer()
            Button(action: {
                triggerHapticFeedback(model: .heavy) // 觸發震動
            }) {
                Image(systemName: "trash") // 垃圾桶
                    .foregroundColor(Color.blue) // 確保顏色存在
                    .frame(width: 30, height: 30) // 設定按鈕大小
                    .background(Color.white) // 白色背景
                    .clipShape(Circle()) // 設定為圓形
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)// 添加陰影
            }
        }
        .padding()
        .background(Color(hex:"#F2F2F2"))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
