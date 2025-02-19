//
//  Loading.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/18.
//

import SwiftUI

struct Loading: View {
    var text: String = "加載中..." // 父層管理選中的 SSID
    @State private var isAnimating = false

    
    var body: some View {
        VStack {
            Image("loading")
                .frame(width: 50, height: 50)
                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0), anchor: .center) // 繞中心旋轉
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
            Text("\(text)")
                .font(.system(size: 14)) // 调整图标大小
                .foregroundColor(Color.g_blue)
        }
    }
}
