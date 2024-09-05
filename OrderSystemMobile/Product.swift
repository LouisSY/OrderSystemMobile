//
//  Product.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 22/08/2024.
//

import Foundation

/// Represents a product available for purchase.
class Product: Identifiable, Codable, Comparable {
    var id: UUID
    var productID: String
    var name: String
    var price: String
    var priceCategory: String
    var foodOrDrink: ProductCategory
    
    /// Initializes a product.
    /// - Parameters:
    ///   - productID: The unique identifier for the product.
    ///   - name: The name of the product.
    ///   - price: The price of the product.
    ///   - foodOrDrink: The category of the product is food or drink
    init(productID: String, name: String, price: String, foodOrDrink: ProductCategory) {
        self.id = UUID() // Default to a new UUID
        self.productID = productID
        self.name = name
        self.price = price
        self.priceCategory = "\(price)元"
        self.foodOrDrink = foodOrDrink
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case productID
        case name
        case price
        case priceCategory
        case foodOrDrink
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.productID = try container.decode(String.self, forKey: .productID)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decode(String.self, forKey: .price)
        self.priceCategory = try container.decode(String.self, forKey: .priceCategory)
        self.foodOrDrink = try container.decode(ProductCategory.self, forKey: .foodOrDrink)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(productID, forKey: .productID)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(priceCategory, forKey: .priceCategory)
        try container.encode(foodOrDrink, forKey: .foodOrDrink)
    }
    
    // MARK: - Comparable
    
    /// Compares two products based on their price and ID.
    /// - Parameters:
    ///   - lhs: The first product to compare.
    ///   - rhs: The second product to compare.
    /// - Returns: A Boolean value indicating whether the first product is less than the second.
    static func < (lhs: Product, rhs: Product) -> Bool {
        if lhs.price != rhs.price {
            return Double(lhs.price) ?? 0 < Double(rhs.price) ?? 0
        }
        return lhs.productID < rhs.productID
    }
    
    /// Checks if two products are equal.
    /// - Parameters:
    ///   - lhs: The first product to compare.
    ///   - rhs: The second product to compare.
    /// - Returns: A Boolean value indicating whether the two products are equal.
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.productID == rhs.productID
    }
}
