//
//  CartItem.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 22/08/2024.
//

import Foundation

/// Represents an item in the shopping cart.
class CartItem: ObservableObject, Identifiable, Codable {
    var id: UUID
    var productID: String
    var name: String
    var price: String
    @Published var quantity: Int
    
    private enum CodingKeys: CodingKey {
        case id, productID, name, price, quantity
    }
    
    /// Initializes a cart item.
    /// - Parameters:
    ///   - id: The unique identifier for the item.
    ///   - productID: The product's identifier.
    ///   - name: The name of the product.
    ///   - price: The price of the product.
    ///   - quantity: The quantity of the product in the cart.
    init(id: UUID, productID: String, name: String, price: String, quantity: Int) {
        self.id = id
        self.productID = productID
        self.name = name
        self.price = price
        self.quantity = quantity
    }
    
    /// Decodes a cart item from a decoder.
    /// - Parameter decoder: The decoder to use.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        productID = try container.decode(String.self, forKey: .productID)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(String.self, forKey: .price)
        quantity = try container.decode(Int.self, forKey: .quantity)
    }
    
    /// Encodes a cart item to an encoder.
    /// - Parameter encoder: The encoder to use.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(productID, forKey: .productID)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(quantity, forKey: .quantity)
    }
}
