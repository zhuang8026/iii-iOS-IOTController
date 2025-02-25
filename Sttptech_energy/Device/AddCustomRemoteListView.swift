//
//  AddCustomRemoteListView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/24.
//

import SwiftUI

struct AddCustomRemoteListView: View {
    @Binding var isRemoteConnected: Bool  // 是否要開始藍芽配對介面，默認：關閉
    @Binding var isRemoteType: String // 父層管理選中的 遙控器類型
    @Binding var editRemoteName: String // 父層管理選中的 自定義遙控器
    
    @State private var remoteTypeName: String = "PANASONIC" // 是否為空值
    @State private var isPowerOn: Bool = false              // 開關控制（父控制）
    @State private var index = 0                            // 追蹤目前文字的索引
    @State private var showRemoteSheet: Bool = false        // 自定義遙控器名稱視窗開關
    
    let brands = ["SANYO_A", "TECO_A", "PANASONIC_A","SANYO_B", "TECO_B", "PANASONIC_B", "SANYO_C", "TECO_C", "PANASONIC_C","SANYO_D", "TECO_D", "PANASONIC_D","SANYO_E", "TECO_E", "PANASONIC_E"]
    let deviceItems = ["PANASONIC HT001XCP01", "PANASONIC HT001XCP02", "PANASONIC HT001XCP03", "PANASONIC HT001XCP04"]
    
    var body: some View {
        VStack(spacing: 20) {
            // 遙控器列表
            if(remoteTypeName == "") {
                HStack {
                    Text("選擇遙控器") // 「標題」
                        .font(.body)
                        .padding(.top, 20)
                }
                ScrollView {
                    // 藍芽裝置列表
                    LazyVStack(spacing: 0) { // `LazyVStack` 會延遲載入，提高效能
                        ForEach(Array(brands.enumerated()), id: \.element) { index, val in
                            Button(action: {
                                print("已選擇：\(index).\(val)")
                                triggerHapticFeedback(model: .heavy) // 觸發震動
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(val)
                                            .font(.body)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading) // ⬅️ 讓文字靠左
                                .background(Color.white) // 按鈕背景顏色
                                .cornerRadius(5) // 圓角
                            }
                            
                            // 🔽 這裡新增分隔線，但最後一個不加
                            if index < brands.count - 1 {
                                Divider()
                                    .frame(height: 1) // 設定 1px 高度
                                    .background(Color.light_gray) // 設定分隔線顏色
                            }
                            
                        }
                        
                    }
                }
                .padding(.horizontal, 20) // 左右邊距，確保刻度在滑桿範圍內
                .background(Color.clear) // 設定整個 `ScrollView` 背景
            } else {
                VStack() {
                    // top: 文字說明
                    VStack(spacing: 9) {
                        Text("選擇遙控器") // 「標題」
                            .font(.body)
                        Text("品牌：\(remoteTypeName)")
                            .font(.body)
                        Text(" 請點擊中心按鈕，確認裝置有回應再點擊保存")
                            .multilineTextAlignment(.center) // 文字換行置中
                            .font(.subheadline)
                        
                    }
                    .padding(.horizontal, 20) // 左右邊距，確保刻度在滑桿範圍內

                    Spacer()
                    
                    // 測試按鈕
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) { // 設定動畫時間為 0.1 秒
                            isPowerOn.toggle()
                        }
                        triggerHapticFeedback() // 觸發震動
                    }) {
                        Image(systemName: "power")
                            .font(.system(size: 80.0))
                            .foregroundColor(isPowerOn ? Color.white : Color.heavy_gray)
                            .padding()
                    }
                    .frame(width: 150, height: 150)
                    .background(isPowerOn ? Color.g_green : Color.light_gray)
                    .shadow(color: Color.black.opacity(0.3), radius: 6, x: -4, y: 4) // 陰影效果
                    .overlay(
                        RoundedRectangle(cornerRadius: 75)
                            .stroke(Color.white, lineWidth: 6) // 添加 3px 白色邊框
                    )
                    .cornerRadius(75)
                    
                    Spacer()
                    
                    // 左右選擇欄位
                    VStack(spacing: 20) {
                        // 文字切換區塊
                        HStack {
                            // 左按鈕
                            Button(action: {
                                index = (index - 1 + deviceItems.count) % deviceItems.count // 向左切換
                            }) {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.g_green))
                            }
                            .padding(.leading, 6) // 靠左邊
                            
                            // 中間的文字
                            Text(deviceItems[index])
                                .font(.body)
                                .foregroundColor(Color.gray)
                                .frame(maxWidth: .infinity, maxHeight: 80.0, alignment: .center) // .leading 讓文字靠左
                            
                            // 右按鈕
                            Button(action: {
                                index = (index + 1) % deviceItems.count // 向右切換
                            }) {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(Color.g_green))
                            }
                            .padding(.trailing, 6) // 靠右邊
                        }
                        .background(Color.light_blue)
                        .cornerRadius(5)
                        
                        // 底部按鈕
                        Button(action: {
                            print("保存按鈕點擊")
                            isRemoteType = deviceItems[index]
                            showRemoteSheet = true
                        }) {
                            Text("保存")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.g_green)
                                .cornerRadius(5)
                        }
                        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: -2)
                        //                    .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20) // 左右邊距，確保刻度在滑桿範圍內
            }
        }
        // 🚀 自定義遙控器 輸入彈窗
        .sheet(isPresented: $showRemoteSheet, onDismiss: {
            // isRemoteType = "" // ✅ 關閉彈窗並清空密碼 配合 onSend()
        }) {
            RemoteInputDialog(
                isRemoteType: $isRemoteType,
                editRemoteName: $editRemoteName,
                isRemoteConnected: $isRemoteConnected
            ){
                showRemoteSheet = false // 點擊送出後關閉
            }
        }
    }
}

//#Preview {
//    AddCustomRemoteListView(isAddRemoteTypeView: .constant(true))
//}
