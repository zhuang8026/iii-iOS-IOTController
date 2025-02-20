//
//  RemoteHeader.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/19.
//

import SwiftUI

struct RemoteHeader: View {
    @Binding var hasControl: Bool // 設備藍芽是否已連線

    var body: some View {
        HStack {
            if (hasControl) {
                Image("remote-control")
                Text("是誰搶走我的遙控器")
                Spacer()
                Button(action: {
                    hasControl = false
                    triggerHapticFeedback(model: .heavy) // 觸發震動
                }) {
                    Image(systemName: "trash") // 垃圾桶
                        .foregroundColor(Color.blue) // 確保顏色存在
                        .frame(width: 30, height: 30) // 設定按鈕大小
                        .background(Color.white) // 白色背景
                        .clipShape(Circle()) // 設定為圓形
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)// 添加陰影
                }
            } else {
                HStack {
                    // tag
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width:  8.0, height: 20.0) // 控制長方形的高度，寬度根據內容自動調整
                    Text("設定")
                }
                Spacer()
                Text("新增遙控器")
                    .frame(maxHeight: 30) // 確保每個 VStack 寬度相等
                    .padding(.horizontal, 12) // 設置左右內邊距為 10 點
                    .background(Color.white) // 白色背景
                    .cornerRadius(20) // 圓角
                Button(action: {
                    hasControl = true
                    triggerHapticFeedback(model: .heavy) // 觸發震動
                }) {
                    Image(systemName: "plus") // 垃圾桶
                        .foregroundColor(Color.blue) // 確保顏色存在
                        .frame(width: 30, height: 30) // 設定按鈕大小
                        .background(Color.white) // 白色背景
                        .clipShape(Circle()) // 設定為圓形
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)// 添加陰影
                }
            }
           
        }
        .padding()
        .background(Color(hex:"#F2F2F2"))
        .cornerRadius(10)
//        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
