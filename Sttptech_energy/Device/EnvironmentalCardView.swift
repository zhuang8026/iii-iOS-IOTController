//
//  EnvironmentalCardView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/23.
//

import SwiftUI

struct EnvironmentalCardView: View {
    var co2: String
    var temperature: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 第一個卡片 (CO₂)
            HStack(alignment: .center, spacing: 8) {
                Image("co2") // CO₂ 圖示 (可換成自定義圖片)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("二氧化碳")
                        .font(.system(size: 14))
                    
                    Text("\(co2)")
                        .font(.system(size: 30, weight: .bold))
                    +
                    Text("ppm")
                        .font(.system(size: 12))
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.5, height: 100)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // 第二個卡片 (溫度)
            HStack(alignment: .center, spacing: 8) {
                Image("normal-temperature") // CO₂ 圖示 (可換成自定義圖片)
                //                        .resizable()
                //                        .scaledToFit()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("溫度")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Text("\(temperature)")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                    +
                    Text("℃")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.40, height: 100)
            .background(Color.g_green) // health: g_green, cold: g_blue, warning: warning
            
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        //            .padding()
        //        .background(Color.light_green) // 背景顏色
        .ignoresSafeArea()
    }
}



//struct EnvironmentalCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        EnvironmentalCardView()
//    }
//}
