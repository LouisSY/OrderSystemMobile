//
//  Decimal+Extensions.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/09/2024.
//

import Foundation

extension Decimal {
    /// Rounds the decimal to a given number of decimal places
    func round(scale: Int) -> Decimal {
        var result = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &result, scale, .plain)
        return rounded
    }
}
