//
//  MultipleDaysStatisticsView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/09/2024.
//

import SwiftUI
import Charts


struct MultipleDaysStatisticsView: View {
    @ObservedObject private var manager = MultipleDaysStatisticsManager()
    @State private var dates: Set<DateComponents> = []
    
    @State var selected: OneDayCurrency?
    
    var body: some View {
        HStack {
            multipleDaysSelector
                .frame(height: 500)
            
            VStack(alignment: .leading) {
                multipleLineChart
                    .padding(.trailing)
                    .padding(.trailing)
                
                if let selected {
                    VStack(alignment: .leading) {
                        Text("日期 \(selected.date.toString())")
                            .font(.title3)
                            .bold()
                        selectedInfo(color: .blue, incomeTitle: "电子货币", amount: selected.currencyResponse.eCurrency)
                        selectedInfo(color: .green, incomeTitle: "现金", amount: selected.currencyResponse.cash)
                        selectedInfo(color: .orange, incomeTitle: "总收入", amount: selected.currencyResponse.sumCurrency)
                    }
                }
            }
        }
    }
    
    /// Multiple Line Chart
    private var multipleLineChart: some View {
        GroupBox("日期统计图") {
            Chart {
                ForEach(manager.multipleDaysCurrency) { item in
                    // 电子货币
                    LineMark(
                        x: .value("日期", item.date),
                        y: .value("金额", item.currencyResponse.eCurrency),
                        series: .value("收入方式", "电子货币")
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(.init(lineWidth: 2))
                    .symbol {
                        Circle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                    }
                    .foregroundStyle(by: .value("收入方式", "电子货币"))
                    
                    // 现金
                    LineMark(
                        x: .value("日期", item.date),
                        y: .value("金额", item.currencyResponse.cash),
                        series: .value("收入方式", "现金")
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(.init(lineWidth: 2))
                    .symbol {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                    }
                    .foregroundStyle(by: .value("收入方式", "现金"))
                    
                    // 现金
                    LineMark(
                        x: .value("日期", item.date),
                        y: .value("金额", item.currencyResponse.sumCurrency),
                        series: .value("收入方式", "总收入")
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(.init(lineWidth: 2))
                    .symbol {
                        Circle()
                            .fill(.orange)
                            .frame(width: 12, height: 12)
                    }
                    .foregroundStyle(by: .value("收入方式", "总收入"))
                    
                    if let selected, Calendar.current.isDate(selected.date, inSameDayAs: item.date) {
                        RuleMark(x: .value("日期", item.date))
                            .lineStyle(.init(lineWidth: 1, miterLimit: 2, dash: [2], dashPhase: 5))
                    }
                }
            }
            .chartOverlay { overlay in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                let location = value.location
                                if let date: Date = overlay.value(atX: location.x) {
                                    withAnimation {
                                        selected = manager.multipleDaysCurrency.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
                                    }
                                }
                            })
                            .onEnded({ value in
                                withAnimation {
                                    selected = nil
                                }
                            })
                    )
            }
        }
        .frame(height: 500)
    }
    
    
    /// Select dates
    private var multipleDaysSelector: some View {
        MultiDatePicker("选择日期", selection: $dates)
            .onChange(of: dates) { oldValue, newValue in
                if oldValue.count < newValue.count {
                    // 新增商品
                    let newDateComponents = newValue.subtracting(oldValue)
                    guard let newDateComponent = newDateComponents.first else {
                        print("Cannot convert from Set<DateComponents> to DateComponents")
                        return
                    }
                    guard let newDate = Calendar.current.date(from: newDateComponent) else {
                        print("Cannot convert from DateComponents to Date")
                        return
                    }
                    manager.fetchStatisticsJson(date: newDate)
                } else {
                    // 删减商品
                    let removedDateComponents = oldValue.subtracting(newValue)
                    guard let removedDateComponent = removedDateComponents.first else {
                        print("Cannot convert from Set<DateComponents> to DateComponents")
                        return
                    }
                    guard let removedDate = Calendar.current.date(from: removedDateComponent) else {
                        print("Cannot convert from DateComponents to Date")
                        return
                    }
                    manager.removeCurrencyInfo(removedDate)
                }
            }
    }
    
    /// Display selected information
    private func selectedInfo(color: Color, incomeTitle: String, amount: Double) -> some View {
        HStack {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(incomeTitle)
            Text(String(describing: amount))
        }
    }
}


#Preview {
    MultipleDaysStatisticsView()
}
