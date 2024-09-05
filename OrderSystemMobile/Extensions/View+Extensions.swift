//
//  View+Extensions.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 22/08/2024.
//

import Foundation
import SwiftUI


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0).padding(.horizontal, 32)
                self
            }
        }
}
