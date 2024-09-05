//
//  ProductCategory.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 24/08/2024.
//

import Foundation

enum ProductCategory: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    case food = "食物"
    case drink = "饮品"
}
