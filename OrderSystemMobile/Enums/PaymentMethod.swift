//
//  PaymentMethod.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 03/06/2024.
//

import Foundation

// 支付方式枚举
enum PaymentMethod: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case 现金, 电子货币, 登月通行证
    
    var imageName: String {
        switch self {
        case .现金:
            return "banknote.fill"
        case .电子货币:
            return "creditcard.viewfinder"
        case .登月通行证:
            return "creditcard.fill"
        }
    }
}

enum AlertState {
    case EmptyList, ConfirmPaymentAlert, LoginAlert
    var id: Self { self }
}
