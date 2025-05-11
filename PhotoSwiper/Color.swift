//
//  Color.swift
//  PhotoSwiper
//
//  Created by Selma Sahin on 09.05.2025.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: Int) {
        self.init(UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0)
        )
    }
}
