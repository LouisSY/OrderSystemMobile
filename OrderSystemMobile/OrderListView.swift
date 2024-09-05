//
//  OrderListView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 01/06/2024.
//

import SwiftUI

import SwiftUI

/// 显示菜单项列表的视图，按类别组织，并允许用户将商品添加到购物车中。
struct OrderListView: View {
    @StateObject private var networkMenuManager = NetworkMenuManager()
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                if networkMenuManager.products.isEmpty {
                    Text("正在加载菜单...")
                        .onAppear {
                            networkMenuManager.fetchCSV()
                        }
                } else {
                    // 将商品按类别分组，方便展示
                    let groupedProducts = Dictionary(grouping: networkMenuManager.products, by: { $0.priceCategory })
                    
                    ForEach(networkMenuManager.categories, id: \.self) { category in
                        Section(header: categoryHeader(category: category)) {
                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: geometry.size.width * 0.15))],
                                spacing: 25
                            ) {
                                if let products = groupedProducts[category] {
                                    ForEach(products) { product in
                                        MenuCard(
                                            product: product,
                                            cartManager: cartManager
                                        )
                                        .frame(
                                            width: geometry.size.width * 0.15,
                                            height: geometry.size.width * 0.15
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .padding(.horizontal)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.orderListBackground)
            .ignoresSafeArea(.keyboard)
        }
    }
    
    /// 返回显示类别名称的视图作为节头。
    /// - Parameter category: 类别名称。
    /// - Returns: 一个视图，表示节头。
    @ViewBuilder
    private func categoryHeader(category: String) -> some View {
        HStack {
            Text(category)
                .font(.title)
                .bold()
                .foregroundColor(.black)
            Spacer()
        }
    }
}

/// 代表菜单项卡片的视图，允许用户将商品添加到购物车中。
struct MenuCard: View {
    var product: Product
    @ObservedObject var cartManager: CartManager
    
    var body: some View {
        Button {
            cartManager.addProduct(product)
        } label: {
            GeometryReader { geometry in
                ZStack {
                    Image(systemName: product.foodOrDrink == .drink ? "waterbottle" : "fork.knife.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: geometry.size.width * 0.4,
                            height: geometry.size.height * 0.4
                        )
                        .foregroundStyle(product.foodOrDrink == .drink ? .cyan : .orange)
                    
                    VStack {
                        Text(product.name)
                            .font(.title3)
                        Spacer()
                        Text("¥\(product.price)")
                            .font(.title3)
                    }
                    .padding(.vertical, 5)
                    .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
            }
        }

    }
}

#Preview {
    ContentView()
}
