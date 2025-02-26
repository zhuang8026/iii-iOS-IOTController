//
//  PopupWindow.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/26.
//

import SwiftUI

struct CustomPopupView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // 半透明黑色背景，擋住點擊事件
            Color.black.opacity(0.5) // 這是半透明背景
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // 不讓點擊背景關閉
                }
            
            VStack(spacing: 20) {
                Text("是否要執行AI決策？")
                    .font(.subheadline)
                    .padding()
                
                VStack(spacing: 10) {
                    ForEach(["1.OOOOOOOOOOOOOOOOOOOOOOOOOOOO", "2.OOOOOOOOOOOOOO", "3.OOOOOOOOOOOOOOOOOOOOOOOO"], id: \.self) { data in
                        Text("\(data)")
                            .font(.body)
//                            .padding()
                    }
                    .frame(maxWidth: .infinity) // 確保 HStack 撐滿父容器
                }
                .padding(.bottom, 20)
                
                HStack {
                    Button("取消") {
                        isPresented = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(30)
                    
                    Button("確定") {
                        isPresented = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
            }
            .padding()
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
        .background(BackgroundBlurView())
    }
}

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

//#Preview {
//    PopupWindow()
//}
