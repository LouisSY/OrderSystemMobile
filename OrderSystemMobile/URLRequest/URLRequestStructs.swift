//
//  URLRequestStructs.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 23/08/2024.
//

import Foundation

/// 发送URL请求 订单
protocol OrderProtocol {
    var cartList: [CartItem] { get }
    var comments: String { get }
    var printReceipt: Bool { get }
}

/// 发送URL请求 用户登月通行证的账号和密码
protocol LoginProtocol {
    var username: String { get }
}

/// 发送URL请求 更新菜单
protocol MenuProtocol {
    var menu: [Product] { get }
}

/// 发送URL请求 储杯和储值权限
protocol PrivilegeProtocol {
    var starAmount: String { get }
    var giftAmount: String { get }
}

/// 发送URL请求 支付方式
protocol PaymentMethodProtocol {
    var paymentMethod: String { get }
}

/// 发送URL请求 姓名
protocol NameProtocol {
    var name: String { get }
}


// MARK: - URL Request Struct
struct OrderRequest: Codable, OrderProtocol, PaymentMethodProtocol {
    let paymentMethod: String
    let cartList: [CartItem]
    let comments: String
    let printReceipt: Bool
}

struct LoginRequest: Codable, OrderProtocol, LoginProtocol, PaymentMethodProtocol {
    let paymentMethod: String
    let cartList: [CartItem]
    let comments: String
    let printReceipt: Bool
    let username: String
}

struct UpdateMenuRequest: Codable, MenuProtocol {
    var menu: [Product]
}

struct TopUpRequest: Codable, LoginProtocol, PrivilegeProtocol, PaymentMethodProtocol {
    var username: String
    var starAmount: String
    var giftAmount: String
    var paymentMethod: String
}

struct NewUserRequest: Codable, NameProtocol, LoginProtocol, PrivilegeProtocol, PaymentMethodProtocol {
    var name: String
    var username: String
    var starAmount: String
    var giftAmount: String
    var paymentMethod: String
}

struct CardInfoRequest: Codable, LoginProtocol {
    var username: String
}

struct ReissueRequest: Codable, LoginProtocol, PaymentMethodProtocol {
    var username: String
    var paymentMethod: String
}
