//
//  OrderTotalView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/06/2024.
//

import SwiftUI

struct OrderTotalView: View {
    @StateObject var networkOrderManager: NetworkOrderManager = NetworkOrderManager()
    
    var body: some View {
        if networkOrderManager.orderDetails.isEmpty {
            Text("正在加载订单...")
                .onAppear {
                    networkOrderManager.fetchCSV()
                }
        } else {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ScrollViewTitle()
                        .frame(width: geometry.size.width, height: 40)
                    ScrollView {
                        ForEach(networkOrderManager.orderDetails) { item in
                            HStack {
                                Text(item.orderID)
                                    .font(.title2)
                                    .bold()
                                    .frame(width: geometry.size.width * 0.1)
                                Spacer()
                                VStack {
                                    ForEach(item.orders) { order in
                                        HStack {
                                            Text(order.productName)
                                                .font(.title2)
                                                .bold()
                                            Spacer()
                                            Text(order.quantity)
                                                .font(.headline)
                                        }
                                    }
                                }
                                .frame(maxWidth: geometry.size.width * 0.13)
                                Spacer()
                                Text(item.time.dropLast(7))
                                    .frame(minWidth: geometry.size.width * 0.2)
                                Spacer()
                                Text(item.comment)
                                    .frame(width: geometry.size.width * 0.1)
                                Spacer()
                                Text(item.payMethod)
                                    .frame(width: geometry.size.width * 0.1)
                                Spacer()
                                if item.status.contains("已完成") {
                                    Image(systemName: "checkmark.circle")
                                        .frame(width: geometry.size.width * 0.1)
                                        .foregroundStyle(.green)
                                        .font(.title)
                                } else {
                                    Image(systemName: "circle.dotted.circle")
                                        .frame(width: geometry.size.width * 0.1)
                                        .foregroundStyle(.red)
                                        .symbolEffect(.pulse)
                                        .font(.title)
                                }
                               
                            }
                            .padding()
                            .foregroundStyle(.black)
                            .background(.white, in: RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                            .opacity(item.status.contains("已完成") ? 0.5 : 1)
                        }
                        Spacer().frame(height: 25)
                    }
                    .padding()
                    .frame(height: geometry.size.height - 40)
                }
                .background(.orderListBackground)
            }
        }
    }
}

struct ScrollViewTitle: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("订单序号")
                    .frame(width: geometry.size.width * 0.1)
                Spacer()
                Text("产品以及数量")
                    .frame(minWidth: geometry.size.width * 0.1)
                Spacer()
                Text("订单时间")
                    .frame(minWidth: geometry.size.width * 0.2)
                Spacer()
                Text("备注")
                    .frame(width: geometry.size.width * 0.1)
                Spacer()
                Text("支付方式")
                    .frame(width: geometry.size.width * 0.1)
                Spacer()
                Text("订单状态")
                    .frame(width: geometry.size.width * 0.1)
            }
            .font(.title3)
            .bold()
            .padding()
            .padding(.horizontal)
            .frame(width: geometry.size.width)
        }
    }
}

#Preview {
    OrderTotalView()
}
