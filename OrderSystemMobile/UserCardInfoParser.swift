//
//  UserCardInfoParser.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 10/06/2024.
//

import Foundation

/// `UserCardInfoParser` 是一个用于解析和管理用户卡信息的类。
/// 该类使用 `@Published` 属性包装器来实时更新 UI 显示的卡信息。
/// 主要功能包括解析从服务器接收到的 JSON 字符串并更新卡信息的详情。
class UserCardInfoParser: ObservableObject {
    
    /// 包含用户卡的详细信息，如用户名、杯数、点数等。
    @Published var cardInfoDetails: CardInfoDetails
    
    /// 存储接收到的字符串信息，用于显示解析失败或错误的情况。
    @Published var receivedString: String = ""
    
    /// 初始化方法，创建一个空的 `CardInfoDetails` 实例。
    init() {
        self.cardInfoDetails = CardInfoDetails(
            username: "",
            pointAmount: "",
            cupAmount: "",
            pointAmountNew: "",
            cupAmountNew: "",
            pointDetails: [ItemDetail(name: "", quantity: 0)],
            cupDetails: [ItemDetail(name: "", quantity: 0)]
        )
    }
    
    /// 解析并更新用户卡信息的 JSON 数据。
    ///
    /// - Parameter receivedJsonString: 从服务器接收到的 JSON 格式的字符串。
    func updateCardInfo(_ receivedJsonString: String) {
        // 清空之前的接收信息
        self.receivedString.removeAll()
        
        // 将字符串转换为 Data 格式
        guard let jsonData = receivedJsonString.data(using: .utf8) else {
            print("Invalid JSON string")
            return
        }
        
        // 尝试解码 JSON 数据
        do {
            let cardInfo = try JSONDecoder().decode(CardInfoDetails.self, from: jsonData)
            
            // 在主线程上更新 cardInfoDetails，以确保 UI 的同步更新
            DispatchQueue.main.async {
                self.cardInfoDetails = cardInfo
            }
        } catch {
            // 如果解析失败，将原始字符串存储在 receivedString 中，并打印错误信息
            self.receivedString = receivedJsonString
            print("Decoding failed: \(error)")
        }
    }
}

/// 表示一个商品的详细信息。
/// 包含商品的名称和数量，并实现了 `Codable`、`Hashable` 和 `Identifiable` 协议。
struct ItemDetail: Codable, Hashable, Identifiable {
    var id: UUID = UUID()  // 自动生成的唯一标识符
    let name: String       // 商品名称
    let quantity: Int      // 商品数量
    
    private enum CodingKeys: String, CodingKey {
        case name, quantity
    }
}

/// 表示用户卡的整体信息。
/// 包含用户名、原始和新的点数及杯数，以及详细的点数和杯数消费明细。
struct CardInfoDetails: Codable {
    let username: String
    let pointAmount: String
    let cupAmount: String
    let pointAmountNew: String
    let cupAmountNew: String
    let pointDetails: [ItemDetail]
    let cupDetails: [ItemDetail]
}
