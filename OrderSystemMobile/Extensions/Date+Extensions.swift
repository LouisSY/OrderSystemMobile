//
//  Date+Extensions.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/09/2024.
//

import Foundation

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
