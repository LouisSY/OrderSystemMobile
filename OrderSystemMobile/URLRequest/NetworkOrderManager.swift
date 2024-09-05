//
//  OrderDetails.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 06/06/2024.
//

import Foundation

class NetworkOrderManager: ObservableObject {
    @Published var orderDetails: [OrderDetailsItem] = []
    
    func fetchCSV() {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: currentDateTime)

        guard let url = URL(string: "http://raspberrypi.local:8360/order/\(dateString)") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data, let csvString = String(data: data, encoding: .utf8) else {
                print("No data or data corrupted")
                return
            }
            
            DispatchQueue.main.async {
                self.parseCSV(csvString: csvString)
            }
        }
        
        task.resume()
    }
    
    private func parseCSV(csvString: String) {
        let lines = csvString.components(separatedBy: "\n")
        var orderDetailsList: [OrderDetailsItem] = []
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            
            let fields = line.components(separatedBy: ",")
            if fields.count >= 8 {
                let orderID = fields[0]
                let phoneNum = fields[1]
                let ordersString = fields[2]
                guard let quantity = Int(fields[3]) else { continue }
                let time = fields[4]
                let comment = fields[5]
                let payMethod = fields[6]
                let status = fields[7]
                
                let orders = [OrderProductItem(productName: ordersString, quantity: "\(quantity)")]
                
                if let index = orderDetailsList.firstIndex(where: { $0.orderID == orderID }) {
                    orderDetailsList[index].orders += orders
                } else {
                    let orderDetailsItem = OrderDetailsItem(
                        orderID: orderID,
                        phoneNum: phoneNum,
                        orders: orders,
                        time: time,
                        comment: comment,
                        payMethod: payMethod,
                        status: status
                    )
                    orderDetailsList.append(orderDetailsItem)
                }
            }
        }
        
        self.orderDetails = orderDetailsList.sorted(by: >)
    }
}


class OrderDetailsItem: Identifiable, ObservableObject, Comparable {
    let id: UUID
    let orderID: String
    let phoneNum: String
    var orders: [OrderProductItem]
    let time: String
    let comment: String
    let payMethod: String
    var status: String
    
    init(orderID: String, phoneNum: String, orders: [OrderProductItem], time: String, comment: String, payMethod: String, status: String) {
        self.id = UUID()
        self.orderID = orderID
        self.phoneNum = phoneNum
        self.orders = orders
        self.time = time
        self.comment = comment
        self.payMethod = payMethod
        self.status = status
    }
    
    static func < (lhs: OrderDetailsItem, rhs: OrderDetailsItem) -> Bool {
        if Int(lhs.orderID)! < Int(rhs.orderID)! {
            return true
        } else {
            return false
        }
    }
    
    static func == (lhs: OrderDetailsItem, rhs: OrderDetailsItem) -> Bool {
        return lhs.orderID == rhs.orderID
    }
}

class OrderProductItem: Identifiable, ObservableObject {
    let id: UUID
    let productName: String
    let quantity: String
    
    init(productName: String, quantity: String) {
        self.id = UUID()
        self.productName = productName
        self.quantity = quantity
    }
}
