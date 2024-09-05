//
//  MultipleDaysStatisticsManager.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/09/2024.
//

import Foundation

/// 用于接收不同种类的currency的具体数值 接收电子货币和现金 并将通过二者计算总收入
struct CurrencyResponse: Codable {
    let eCurrency: Double
    let cash: Double
    
    var sumCurrency: Double {
        let eCurrencyRounded = Decimal(eCurrency).round(scale: 2)
        let cashRounded = Decimal(cash).round(scale: 2)
        let sum = eCurrencyRounded + cashRounded
        return Double(truncating: sum as NSDecimalNumber)
    }
}

/// 将`CurrencyResponse`与`Date`结合
struct OneDayCurrency: Identifiable, Comparable {
    static func < (lhs: OneDayCurrency, rhs: OneDayCurrency) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func == (lhs: OneDayCurrency, rhs: OneDayCurrency) -> Bool {
        return lhs.date == rhs.date
    }
    
    let id = UUID()
    let date: Date
    let currencyResponse: CurrencyResponse
}

/// 用于处理多日期收入统计
class MultipleDaysStatisticsManager: ObservableObject {
    @Published var multipleDaysCurrency: [OneDayCurrency] = []
    
    func fetchStatisticsJson(date: Date) {
        let dateString = date.toString()
        print("Looking for date \(dateString)")
        
        guard let url = URL(string: "http://raspberrypi.local:8360/multiple-statistics/\(dateString)") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            DispatchQueue.main.async {
                self.multipleDaysCurrency.append(OneDayCurrency(date: date, currencyResponse: self.parseJSONData(data)))
                self.multipleDaysCurrency = self.multipleDaysCurrency.sorted(by: <)
            }
        }
        
        task.resume()
    }
    
    func parseJSONData(_ data: Data) -> CurrencyResponse {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(CurrencyResponse.self, from: data)
            print("eCurrency: \(response.eCurrency)")
            print("cash: \(response.cash)")
            return CurrencyResponse(eCurrency: response.eCurrency, cash: response.cash)
        } catch {
            print("Failed to parse JSON data: \(error)")
            return CurrencyResponse(eCurrency: 0, cash: 0)
        }
    }
    
    func removeCurrencyInfo(_ date: Date) {
        multipleDaysCurrency = multipleDaysCurrency.filter({ $0.date != date })
    }
}
