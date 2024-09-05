//
//  CartManager.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 03/06/2024.
//

import Foundation

/// Manages the items in the shopping cart.
class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    
    /// Adds a product to the cart. Increments quantity if the product already exists.
    /// - Parameter product: The product to be added.
    func addProduct(_ product: Product) {
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            // If the product already exists, increment quantity
            items[index].quantity += 1
            objectWillChange.send()
        } else {
            // If the product does not exist, add as new item
            let newItem = CartItem(id: product.id, productID: product.productID, name: product.name, price: product.price, quantity: 1)
            items.append(newItem)
        }
    }
    
    /// Increments the quantity of a specific cart item.
    /// - Parameter cartItem: The cart item to be incremented.
    func cartListPlusOperation(_ cartItem: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == cartItem.id }) else { return }
        items[index].quantity += 1
        objectWillChange.send()
    }
    
    /// Decrements the quantity of a specific cart item. Removes the item if quantity reaches zero.
    /// - Parameter cartItem: The cart item to be decremented.
    func cartListMinusOperation(_ cartItem: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == cartItem.id }) else { return }
        items[index].quantity -= 1
        if items[index].quantity == 0 {
            items.remove(at: index)
        }
        objectWillChange.send()
    }
    
    /// Computes the total price of all items in the cart.
    var totalPrice: Decimal {
        items.reduce(0) { $0 + Decimal(Double($1.price) ?? 0) * Decimal($1.quantity) }
    }
}

