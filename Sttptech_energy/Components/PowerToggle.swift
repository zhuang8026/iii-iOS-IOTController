//
//  PowerToggle.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/21.
//

import SwiftUI

/// 電源切換視圖
struct PowerToggle: View {
    @Binding var isPowerOn: Bool

    @State private var didAppear = false
    var onToggle: ((Bool) -> Void)? = nil


    var body: some View {
        HStack {
            Image(systemName: "power")
            Text("電源")
            Spacer()
            HStack () {
                Toggle(isOn: $isPowerOn) {
                    Text(isPowerOn ? "開" : "關")  // 根據 isPowerOn 顯示開或關
                        .foregroundColor(isPowerOn ? Color(hex:"#1FA2A0") : .gray)  // 更改文字顏色
                    // .padding(.trailing, 3)  // 讓 Text 與 Toggle 之間有 6px 間距
                }
                .tint(Color(hex:"#1FA2A0"))
                .toggleStyle(.switch)
                .padding(0)
                //                    .onChange(of: isPowerOn) { val in
                //                        onToggle?(val)
                //                    }
                .onChange(of: isPowerOn) { val in
                    if didAppear {
                        onToggle?(val)
                    }
                }
            }
            .frame(width: 80)
        }
        .padding()
        .background(Color(hex:"#F2F2F2"))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .onAppear {
            // 畫面首次顯示後，才允許觸發 onChange
            DispatchQueue.main.async {
                didAppear = true
            }
        }
    }
}
