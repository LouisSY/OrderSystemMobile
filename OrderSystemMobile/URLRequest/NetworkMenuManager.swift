//
//  NetworkMenuManager.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 01/06/2024.
//

import Foundation

/// `NetworkMenuManager` 是一个用于管理和处理菜单数据的类。它从远程服务器获取 CSV 文件，解析数据，并对产品列表进行排序和分类。
class NetworkMenuManager: ObservableObject {
    /// 存储从服务器获取的产品列表
    @Published var products: [Product] = []
    
    /// 存储产品类别
    @Published var categories: [String] = []
    
    /// 从服务器获取 CSV 文件并处理数据
    ///
    /// 该方法发送一个 HTTP GET 请求到指定的 URL，下载 CSV 文件内容，并将其传递给 `parseCSV` 方法进行解析。
    /// 解析完成后，会调用 `sortProductList` 方法对产品列表进行排序和分类。
    func fetchCSV() {
        guard let url = URL(string: NSLocalizedString("menu", comment: "URL for menu")) else {
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
                self.sortProductList()
            }
        }
        
        task.resume()
    }
    
    /// 解析 CSV 字符串并将其转换为 `Product` 对象
    ///
    /// 该方法将 CSV 字符串分解为行，然后按行拆分字段，将每个产品的信息创建为 `Product` 对象，并将其添加到 `products` 列表中。
    /// 跳过 CSV 文件的第一行（标题行）。
    ///
    /// - Parameter csvString: 从服务器获取的 CSV 文件内容字符串
    private func parseCSV(csvString: String) {
        let lines = csvString.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() {
            if index == 0 {
                // 跳过标题行
                continue
            }
            
            let fields = line.components(separatedBy: ",")
            if fields.count >= 3 {
                let product = Product(
                    productID: fields[0],
                    name: fields[1],
                    price: fields[2],
                    foodOrDrink: fields[3].contains("食物") ? .food : .drink
                )
                self.products.append(product)
            }
        }
    }
    
    /// 对产品列表进行排序并更新类别列表
    ///
    /// 该方法首先对 `products` 列表中的产品进行排序。然后，将每个产品的类别添加到 `categories` 列表中，确保类别列表中的每个类别都是唯一的。
    func sortProductList() {
        self.products = self.products.sorted(by: >)
        for product in self.products {
            if !self.categories.contains(product.priceCategory) {
                self.categories.append(product.priceCategory)
            }
        }
    }
}
