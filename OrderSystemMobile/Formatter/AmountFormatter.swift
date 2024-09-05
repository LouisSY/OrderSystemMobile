//
//  AmountFormatter.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 25/08/2024.
//

import Foundation

/// 检查输入的数字是否符合格式
/// - Parameters:
///   - oldValue: 输入之前原本的`String`
///   - newValue: 输入之后新的`String`
/// - Returns: 重新规范格式之后的`String`
/// - 数字为正小数或正整数
/// - 小数位最大是2位
/// - 数字不能大于1000
/// - 这个String可以是`""`
func amountFormatter(oldValue: String, newValue: String) -> String {
    if newValue.isEmpty {
        return newValue
    }
    let filterValue = newValue.filter("0123456789.".contains(_:))
    if filterValue != newValue {
        return filterValue
    }
    let components = newValue.split(separator: ".")
    if components.count > 2 {
        return oldValue
    } else if components.count == 2 && components[1].count > 2 {
        return oldValue
    }
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    guard let newNumber = numberFormatter.number(from: newValue) else {
        return oldValue
    }
    if newNumber.doubleValue > 1000 {
        return "1000"
    }
    return newValue
}
