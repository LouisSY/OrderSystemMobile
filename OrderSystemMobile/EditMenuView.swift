//
//  EditMenuView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 28/06/2024.
//

import SwiftUI

/// 菜单编辑视图，允许用户查看、编辑和管理菜单项。
struct EditMenuView: View {
    @StateObject private var networkMenuManager = NetworkMenuManager()
    @State private var products: [Product] = []
    @State private var priceCategories: [String] = []
    
    // 是否展示用于加入新商品的sheet
    @State private var isShowingSheet: Bool = false
    
    // 是否展示Alert以及Alert的标题和内容
    @State private var isShowingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            if networkMenuManager.products.isEmpty {
                Text("正在加载菜单...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .font(.title)
                    .onAppear {
                        networkMenuManager.fetchCSV()
                    }
            } else {
                NavigationStack {
                    List {
                        ForEach(priceCategories, id: \.self) { category in
                            Section(category) {
                                ForEach(products.filter { $0.priceCategory == category }, id: \.id) { product in
                                    HStack {
                                        Text(product.name)
                                        Spacer()
                                        Image(systemName: product.foodOrDrink == .drink ? "waterbottle" : "fork.knife.circle")
                                            .foregroundStyle(product.foodOrDrink == .drink ? .cyan : .orange)
                                        Text(product.price)
                                            .frame(width: 50)
                                    }
                                }
                                .onDelete { indexSet in
                                    deleteItem(at: indexSet, category: category)
                                }
                                .onMove { indexSet, offset in
                                    moveItem(from: indexSet, to: offset, category: category)
                                }
                            }
                        }
                    }
                    .navigationTitle("编辑菜单")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            EditButton()
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                products.removeAll()
                                priceCategories.removeAll()
                            } label: {
                                Text("清空")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isShowingSheet = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                generateNewID()
                                let updateMenuRequest = UpdateMenuRequest(
                                    menu: products
                                )
                                sendRequest(urlString: NSLocalizedString("updateMenu", comment: "URL for uploading new menu"), requestBody: updateMenuRequest) { result in
                                    switch result {
                                    case .success(let message):
                                        alertTitle = "菜单更新成功"
                                        alertMessage = "菜单已成功上传至网络"
                                        isShowingAlert = true
                                        print("Success: \(message)")
                                    case .failure(let error):
                                        alertTitle = "出现问题"
                                        alertMessage = "请检查网络连接后再次尝试"
                                        isShowingAlert = true
                                        print("Error: \(error.localizedDescription)")
                                    }
                                }
                            } label: {
                                Text("提交")
                            }
                            .disabled(products.isEmpty)
                        }
                    }
                }
                .onAppear {
                    products = networkMenuManager.products
                    priceCategories = networkMenuManager.categories
                }
                .animation(.easeInOut, value: products)
                .frame(width: geometry.size.width)
                .sheet(isPresented: $isShowingSheet, onDismiss: {
                    generateNewID()
                }) {
                    AddProductSheet(
                        isPresented: $isShowingSheet,
                        products: $products,
                        priceCategories: $priceCategories
                    )
                    .interactiveDismissDisabled()
                }
                .alert(alertTitle, isPresented: $isShowingAlert) {
                    Button {
                        isShowingAlert = false
                    } label: {
                        Text("确认")
                    }

                } message: {
                    Text(alertMessage)
                }
            }
        }
        .background(Color.orderListBackground)
    }
    
    /// 删除指定类别中的商品项
    /// - Parameters:
    ///   - indexSet: 要删除的商品项的索引
    ///   - category: 商品所在的类别
    func deleteItem(at indexSet: IndexSet, category: String) {
        // 确定要删除的商品项在全局列表中的索引
        let indexes = indexSet.map { index in
            products.firstIndex { $0.id == products.filter { $0.priceCategory == category }[index].id }!
        }
        indexes.forEach { index in
            products.remove(at: index)
        }
        
        // 如果类别下没有任何商品，删除该类别
        if products.filter({ $0.priceCategory == category }).isEmpty {
            priceCategories.removeAll { $0 == category }
        }
    }
    
    
    /// 移动商品项在指定类别中
    /// - Parameters:
    ///   - indexSet: 源索引
    ///   - offset: 目标索引
    ///   - category: 商品所在的类别
    func moveItem(from indexSet: IndexSet, to offset: Int, category: String) {
        // 获取类别在全局列表中的起始索引
        let globalIndex = products.firstIndex { $0.priceCategory == category } ?? 0
        
        // 计算源索引和目标索引
        var sourceIndices: [Int] = []
        for index in indexSet {
            sourceIndices.append(index + globalIndex)
        }
        
        let toIndex = offset + globalIndex
        
        // 执行移动操作
        products.move(fromOffsets: IndexSet(sourceIndices), toOffset: toIndex)
    }
    
    /// 生成新商品的ID
    /// 产品ID的格式为 "categoryID-productID"，其中 categoryID 和 productID 都具有动态长度，至少为 4 位。
    func generateNewID() {
        priceCategories = sortPriceCategoriesList()
        let maxCategoryIndex = priceCategories.count - 1
        let digitCountCategory = max(String(maxCategoryIndex).count, 4)
        
        let categoryIDs = priceCategories.enumerated().reversed().map { (index, _) in
            String(format: "%0\(digitCountCategory)d", index)
        }
        
        for (indexCategory, category) in priceCategories.enumerated() {
            let productList = products.filter { $0.priceCategory == category }
            let maxProductIndex = productList.count - 1
            let digitCountProduct = max(String(maxProductIndex).count, 4)
            
            let productIDs = productList.enumerated().reversed().map { (index, _) in
                String(format: "%0\(digitCountProduct)d", index)
            }
            for (indexProduct, product) in productList.enumerated() {
                product.productID = "\(categoryIDs[indexCategory])-\(productIDs[indexProduct])"
            }
        }
        products = products.sorted(by: >)
    }
    
    /// 对`priceCategories`进行排序
    func sortPriceCategoriesList() -> [String] {
        // 定义一个正则表达式来匹配价格部分
        let regex = try! NSRegularExpression(pattern: "[0-9]+\\.?[0-9]*", options: [])
        
        // 解析价格字符串为数值
        func extractPrice(_ priceString: String) -> Double? {
            let range = NSRange(location: 0, length: priceString.utf16.count)
            if let match = regex.firstMatch(in: priceString, options: [], range: range) {
                let priceValue = (priceString as NSString).substring(with: match.range)
                return Double(priceValue)
            }
            return nil
        }
        
        // 根据价格数值进行排序
        let sortedPriceList = priceCategories.sorted {
            (extractPrice($0) ?? 0) > (extractPrice($1) ?? 0)
        }
        
        return sortedPriceList
    }
}

/// 商品添加视图，允许用户输入新商品的名称、价格和类别，并将其添加到商品列表中。
///
/// - Parameters:
///   - isPresented: 控制视图是否显示的绑定变量。
///   - products: 绑定到当前商品列表的变量，当添加新商品时会更新此列表。
///   - priceCategories: 绑定到当前价格类别列表的变量，当添加新商品时会更新此列表。
struct AddProductSheet: View {
    @Binding var isPresented: Bool
    @Binding var products: [Product]
    @Binding var priceCategories: [String]
    
    @State private var productName: String = ""
    @State private var productPrice: Double = 18
    @State private var selectedCategory: ProductCategory = .drink
    
    private let categories: [ProductCategory] = ProductCategory.allCases
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("商品信息")) {
                    TextField("商品名称", text: $productName)
                    
                    HStack {
                        Text("商品价格")
                        Spacer()
                        Stepper(value: $productPrice, in: 1...50, step: 0.1) {
                            TextField("Value", value: $productPrice, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                                .padding()
                                .onChange(of: productPrice) { oldValue, newValue in
                                    productPrice = productPriceFormatter(productPrice)
                                }
                        }
                        .frame(width: 200)
                        .padding(.horizontal)
                    }
                    
                    Picker("选择类别", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("添加新商品")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        clearInputs()
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addNewProduct()
                        clearInputs()
                        isPresented = false
                    }
                    .disabled(productName.isEmpty)
                }
            }
        }
    }
    
    /// 添加新商品到商品列表，并更新价格类别列表。
    ///
    /// 创建一个新的 `Product` 对象，并将其添加到 `products` 列表中。如果 `priceCategories` 列表中不包含新商品的价格类别，则将其添加到 `priceCategories` 列表中。
    private func addNewProduct() {
        let newProduct = Product(
            productID: "0000-0000",
            name: productName,
            price: String(describing: Decimal(productPrice)),
            foodOrDrink: selectedCategory
        )
        
        // 打印新商品的信息（调试用）
        print(newProduct.name)
        print(newProduct.price)
        print(newProduct.priceCategory)
        print(newProduct.foodOrDrink)
        
        // 将新商品添加到商品列表
        products.append(newProduct)
        
        // 如果价格类别列表中不包含新商品的类别，则添加该类别
        if !priceCategories.contains(newProduct.priceCategory) {
            priceCategories.append(newProduct.priceCategory)
        }
    }
    
    /// 清空输入字段，重置商品名称和价格。
    ///
    /// 将 `productName` 和 `productPrice` 重置为初始值，以便在视图关闭后重新使用。
    private func clearInputs() {
        productName = ""
        productPrice = 18
    }
    
    /// 格式化商品价格，确保价格为有效的正数并且精确到一位小数。
    ///
    /// 这个函数首先检查价格是否有效，确保价格大于零，并且转换后的结果最多只有一个小数点。如果价格不符合要求，将返回一个默认值（1.0）。
    ///
    /// - Parameter input: 需要格式化的商品价格，类型为 `Double`。
    /// - Returns: 格式化后的商品价格，类型为 `Double`，确保精确到一位小数。
    ///
    /// - Note: 如果输入价格小于或等于零，或输入无效，将返回一个有效的默认价格（1.0）。
    func productPriceFormatter(_ input: Double) -> Double {
        // 确保价格是正数
        if input <= 0 {
            return 1.0
        }
        
        // 格式化为一位小数
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        
        // 将输入的 Double 转换为符合要求的字符串，并解析回 Double
        let formattedString = formatter.string(from: NSNumber(value: input)) ?? "1.0"
        return Double(formattedString) ?? 1.0
    }
}


#Preview {
    EditMenuView()
}
