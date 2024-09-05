//
//  NetworkStatisticsManager.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/06/2024.
//

import Foundation
import Combine

class NetworkStatisticsManager: ObservableObject {
    @Published var statisticsJson: String = ""
    @Published var statisticsData: StatisticsData?
    @Published var incomeDetail: [IncomeSummaryItem] = []
    @Published var orderDetail: [ProductAmount] = []

    func fetchStatisticsJson(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        print("looking for date \(dateString)")
        
        guard let url = URL(string: "http://raspberrypi.local:8360/statistics/\(dateString)") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data, let jsonString = String(data: data, encoding: .utf8) else {
                print("No data or data corrupted")
                return
            }
            
            DispatchQueue.main.async {
                self.statisticsJson = jsonString
                self.parseStatisticsJson(jsonString: jsonString)
            }
        }
        
        task.resume()
    }
    
    private func parseStatisticsJson(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Unable to convert string to Data")
            return
        }
        
        do {
            let statistics = try JSONDecoder().decode(StatisticsData.self, from: jsonData)
            self.statisticsData = statistics
            
            incomeDetail = statisticsData!.incomeSummary.map {
                IncomeSummaryItem(category: $0.category, income: $0.income)
            }

            orderDetail = statisticsData!.ordersDetails.map {
                ProductAmount(productName: $0.productName, quantity: $0.quantity)
            }
            orderDetail = orderDetail.sorted(by: >)
        } catch {
            print("Failed to decode JSON: \(error)")
            incomeDetail.removeAll()
            orderDetail.removeAll()
            statisticsData?.orderNum = 0
            statisticsData?.incomeSum = "0"
        }
    }
}


/// 每种收入方式的收入
struct IncomeSummaryItem: Codable, Identifiable {
    let id: UUID = UUID()
    let category: String
    let income: String
    
    private enum CodingKeys: String, CodingKey {
        case category, income
    }
}

/// 每个产品的数量
struct ProductAmount: Codable, Comparable, Identifiable {
    let id: UUID = UUID()
    let productName: String
    let quantity: String
    
    private enum CodingKeys: String, CodingKey {
        case productName, quantity
    }
    
    static func < (lhs: ProductAmount, rhs: ProductAmount) -> Bool {
        if Int(lhs.quantity)! < Int(rhs.quantity)! {
            return true
        } else {
            return false
        }
    }
    
    static func == (lhs: ProductAmount, rhs: ProductAmount) -> Bool {
        return lhs.productName == rhs.productName && lhs.quantity == rhs.quantity
    }
}


/// 接收到的jsonString的内容
struct StatisticsData: Codable {
    let incomeSummary: [IncomeSummaryItem]
    var incomeSum: String
    var orderNum: Int
    let ordersDetails: [ProductAmount]
}
