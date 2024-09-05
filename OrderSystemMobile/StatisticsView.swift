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
    
    var body: some View {
        TabView {
            OneDayStatisticsView(networkStatisticsManager: networkStatisticsManager)
                .tabItem {
                    Label("单日统计", systemImage: "calendar")
                }
            
            MultipleDaysStatisticsView()
                .tabItem {
                    Label("多日统计", systemImage: "aspectratio.fill")
                }
        }
    }
}



#Preview {
    StatisticsView()
}
