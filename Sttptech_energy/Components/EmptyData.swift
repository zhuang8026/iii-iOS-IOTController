//
//  EmptyData.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/18.
//

import SwiftUI

struct EmptyData: View {
    var text: String = "暫無設備" // 父層管理選中

    var body: some View {
        VStack {
            Image("empty")
                .frame(width: 50, height: 50)
            Text("\(text)")
                .font(.system(size: 14)) // 调整图标大小
                .foregroundColor(Color.g_blue)
        }
    }
}

#Preview {
    EmptyData()
}
