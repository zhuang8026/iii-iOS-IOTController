//
//  ACnumber.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/23.
//

import SwiftUI

struct ACnumber: View {
    @Binding var fanSpeed: Double // 滑桿的當前值
    @Binding var temperature: Int // 初始溫度
 
    var body: some View {
        /// 風速和空調溫度顯示
        VStack(alignment: .leading, spacing: 0) { // .leading: 左对齐, .trailing: 右对齐, .center: 水平居中对齐
            HStack(alignment: .center, spacing: 4) { // 文字和数字水平排列
                Text("\(Int(fanSpeed))")
                    .font(.system(size: 60)) // 設置文字大小60
                    .frame(width: 40, alignment: .center)
                Text("/")
                    .padding(.horizontal, 10) // 設置左右內邊距為 10 點
                Text("\(temperature)°")
                    .font(.system(size: 60)) // 設置文字大小60
                    .frame(width: 120, alignment: .center)
            }
            HStack () {
                Text("風速")
                    .frame(width: 40, alignment: .center)
                Spacer()
                Text("空調溫度")
                    .frame(width: 120, alignment: .center)
            }
                .frame(maxWidth: 180) // 根据需要调整宽度，确保与上方对齐
                .font(.subheadline)
                .foregroundColor(.gray)
        }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
