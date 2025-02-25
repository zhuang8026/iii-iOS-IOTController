//
//  RemoteInputDialog.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/25.
//

import SwiftUI

struct RemoteInputDialog: View {
    @Binding var isRemoteType: String  // 父層傳入 (單向傳遞，不會更改)
    @Binding var editRemoteName: String  // 父層傳入 (密碼需要雙向綁定)
    @Binding var isRemoteConnected: Bool // 父層傳入 (設備藍芽是否已連線)

    @State private var isLoading: Bool = false // 送出Wifi密碼狀態
    @FocusState private var isTextFieldFocused: Bool  // 追蹤輸入框焦點
    
        var onSend: () -> Void

    var body: some View {
        VStack {
            Text("編輯遙控器")
                .font(.title3)
                .bold()
                .padding(.top, 5)
            
            // 遙控器列表名稱
            Text(isRemoteType)
                .font(.title3)
                .bold()
                .padding(.top, 5)
            
            // 加載動畫
            if (isLoading) {
                VStack {
                    Spacer()
                    Loading(text: "連線中")
                    Spacer()
                }
            } else {
                HStack {
                    // 🔐 自定義遙控器輸入框
                    TextField("請輸入遙控器名稱", text: $editRemoteName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .focused($isTextFieldFocused)

                    // 📩 送出按鈕
                    Button(action: {
//                        print("連接類型 \(isRemoteType)，修改為：\(editRemoteName)")
                        
                        isLoading = true //  開啟 loading 動畫
                        if !isRemoteType.isEmpty && !editRemoteName.isEmpty {
                            print("✅ 開始寫入-> 自定義遙控器名稱/\(editRemoteName)")
                            
                            isRemoteConnected = false // ✅ 遙控器更新成功
                            isLoading = false // 關閉 loading 動畫
                            onSend() // 關閉子視窗
                            
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(editRemoteName.isEmpty ? Color.light_gray: Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(isRemoteType.isEmpty || editRemoteName.isEmpty)
                }
                .padding()
            } // if end
        }
        .padding()
        .presentationDetents([.height(200.0), .height(200.0)]) // 固定高度
        .presentationDragIndicator(.visible) // 顯示拖曳指示條
    }
}
