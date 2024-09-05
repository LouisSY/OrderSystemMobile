//
//  PhoneNumFormatter.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 25/08/2024.
//

import Foundation

/// 规范手机号码的输入格式
/// - Parameter phoneNum: 输入的手机号码
/// - Returns: 符合格式的手机号码
func phoneNumFormatter(phoneNum: String) -> String {
    var formattedPhoneNum = phoneNum
    
    // 限制输入长度为 11
    if formattedPhoneNum.count > 11 {
        formattedPhoneNum = String(formattedPhoneNum.prefix(11))
    }
    
    // 输入必须全部是数字
    let isValid = formattedPhoneNum.allSatisfy { $0.isNumber }
    if !isValid {
        formattedPhoneNum = String(formattedPhoneNum.dropLast())
    }
    
    return formattedPhoneNum
}
