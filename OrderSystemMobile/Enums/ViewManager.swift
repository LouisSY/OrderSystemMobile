//
//  ViewManager.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/06/2024.
//

import Foundation

enum ViewGroup: String, CaseIterable, Identifiable {
    case 主页, 订单, VIP, 统计, 修改, 菜单
    var id: Self { self }
}
