//
//  ContentView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 01/06/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var cartManager = CartManager()
    @State var viewGroup: ViewGroup = .主页
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                switch viewGroup {
                case .主页:
                    OrderListView()
                        .frame(
                            width: geometry.size.width * 0.7,
                            height: geometry.size.height
                        )
                    OperationListView()
                        .frame(
                            width: geometry.size.width * 0.27,
                            height: geometry.size.height
                        )
                case .订单:
                    OrderTotalView()
                        .frame(
                            width: geometry.size.width * 0.97,
                            height: geometry.size.height
                        )
                case .VIP:
                    NewVIPView()
                        .frame(
                            width: geometry.size.width * 0.97,
                            height: geometry.size.height
                        )
                case .统计:
                    StatisticsView()
                        .frame(
                            width: geometry.size.width * 0.97,
                            height: geometry.size.height
                        )
                case .修改:
                    EditMenuView()
                        .frame(
                            width: geometry.size.width * 0.97,
                            height: geometry.size.height
                        )
                case .菜单:
                    MenuImageView()
                        .frame(
                            width: geometry.size.width * 0.97,
                            height: geometry.size.height
                        )
                }
                ToolBarView(viewGroup: $viewGroup)
                    .frame(
                        width: geometry.size.width * 0.03,
                        height: geometry.size.height
                    )
            }
            .environmentObject(cartManager)
        }
    }
}

#Preview {
    ContentView()
}
