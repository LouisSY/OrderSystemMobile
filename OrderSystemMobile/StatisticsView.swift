//
//  StatisticsView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/06/2024.
//

import SwiftUI
import Charts

/// 统计视图，显示收入和订单数据的仪表盘。
struct StatisticsView: View {
    @ObservedObject private var networkStatisticsManager = NetworkStatisticsManager()
    @State private var date = Date.now

    var body: some View {
        GeometryReader { geometry in
            HStack {
                datePicker
                    .frame(width: 300)
                    .padding(.leading, 100)
                VStack {
                    if networkStatisticsManager.statisticsJson.isEmpty {
                        Text("正在加载...")
                            .foregroundStyle(.black)
                            .onAppear {
                                networkStatisticsManager.fetchStatisticsJson(date: date)
                            }
                    } else {
                        // 显示收入仪表盘和订单仪表盘
                        IncomeDashBoard(networkStatisticsManager: networkStatisticsManager)
                        OrderDashBoard(networkStatisticsManager: networkStatisticsManager)
                    }
                }
            }
            .background(.orderListBackground)
        }
    }
    
    
    private var datePicker: some View {
        DatePicker(selection: $date, in: ...Date.now, displayedComponents: .date) {
            Text("日期")
        }
        .datePickerStyle(.graphical)
        .padding()
        .background(.white, in:  RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .shadow(radius: 10)
        .onChange(of: date) { oldValue, newValue in
            networkStatisticsManager.fetchStatisticsJson(date: newValue)
        }

    }
}

/// 显示收入统计
struct IncomeDashBoard: View {
    @ObservedObject var networkStatisticsManager: NetworkStatisticsManager

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 30) {
                // 显示收入饼状图
                Chart(networkStatisticsManager.incomeDetail) { element in
                    SectorMark(angle: .value("income", Double(element.income) ?? 0), innerRadius: .ratio(0.8), angularInset: 3)
                        .cornerRadius(10)
                        .foregroundStyle(by: .value("name", element.category))
                }
                .chartLegend(.hidden)
                .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                
                VStack(spacing: geometry.size.height * 0.03) {
                    // 显示收入详细信息
                    ForEach(networkStatisticsManager.incomeDetail) { item in
                        HStack {
                            Text(item.category)
                                .font(.title2)
                                .bold()
                            Spacer()
                            Text("\(Decimal(Double(item.income) ?? 0))")
                                .font(.headline)
                        }
                        .frame(
                            maxWidth: geometry.size.width * 0.3,
                            maxHeight: geometry.size.height * 0.15
                        )
                    }
                    // 显示总收入
                    let incomeSum = networkStatisticsManager.statisticsData?.incomeSum ?? "0"
                    Text("总收入: \(incomeSum)")
                        .font(.title)
                        .bold()
                }
                .foregroundStyle(.black)
            }
            .padding()
            .background(.white, in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .shadow(radius: 20)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

/// 显示商品售出统计
struct OrderDashBoard: View {
    @ObservedObject var networkStatisticsManager: NetworkStatisticsManager

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 30) {
                // 显示订单饼状图
                Chart(networkStatisticsManager.orderDetail) { element in
                    SectorMark(angle: .value("quantity", Double(element.quantity) ?? 0), innerRadius: .ratio(0.8), angularInset: 3)
                        .cornerRadius(10)
                        .foregroundStyle(by: .value("productName", element.productName))
                }
                .chartLegend(.hidden)
                .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                
                VStack(spacing: geometry.size.height * 0.03) {
                    // 显示订单详细信息
                    ScrollView {
                        ForEach(networkStatisticsManager.orderDetail) { item in
                            HStack {
                                Text(item.productName)
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Text("\(Decimal(Double(item.quantity) ?? 0))")
                                    .font(.headline)
                            }
                            .frame(
                                maxWidth: geometry.size.width * 0.3,
                                maxHeight: geometry.size.height * 0.2
                            )
                        }
                        .padding()
                    }
                    .frame(height: geometry.size.height * 0.6)
                    
                    // 显示卖出商品数量
                    let orderNum = networkStatisticsManager.statisticsData?.orderNum ?? 0
                    Text("卖出商品数量: \(orderNum)")
                        .font(.title)
                        .bold()
                }
                .foregroundStyle(.black)
            }
            .padding()
            .background(.white, in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .shadow(radius: 20)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    StatisticsView()
}
