//
//  AnimationModels.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/18.
//

import SwiftUI

// .light（輕）
// .medium（中）
// .heavy（重）
// .soft（柔和）
// .rigid（剛硬）
func triggerHapticFeedback(model: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    print("震動")
    let generator = UIImpactFeedbackGenerator(style: model) // 震動樣式（輕、中、重）
    generator.prepare()
    generator.impactOccurred() // 觸發震動
}
