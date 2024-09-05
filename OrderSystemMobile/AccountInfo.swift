//
//  AccountInfo.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 29/08/2024.
//

import Foundation

/// Account Information, including cardholder's name, star amount and moon amount
struct AccountInfo: Codable {
    var name: String
    var phoneNum: String
    var starAmount: String
    var moonAmount: String
}
