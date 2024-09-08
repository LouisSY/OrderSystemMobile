//
//  OperationListView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 01/06/2024.
//

import SwiftUI

/// 主视图，显示订单操作列表
struct OperationListView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var commentText: String = ""
    @State private var isEditing: Bool = false
    @State private var selectedPaymentMethod: PaymentMethod = .电子货币
    @State private var printReciept: Bool = true
    
    // 点击提交按钮显示的弹窗
    @State private var isShowingAlert: Bool = false
    @State private var alertState: AlertState = .EmptyList
    @State private var alertTitle: String = "还没选择商品"
    @State private var alertContent: String = "请在商品列表中选取商品后再提交订单!"
    
    // 登月通行证账户
    @State private var accountID: String = ""
    
    @State private var isShowingLoginSheet: Bool = false
    @ObservedObject var userCardInfoParser: UserCardInfoParser = UserCardInfoParser()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {

                // 头部视图，显示标题和清空购物车按钮
                HeaderView(cartManager: _cartManager)
                    .padding(.horizontal)
                
                // 显示购物车中的商品列表
                CartList(cartManager: cartManager)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * 0.45
                    )
                
                // 显示订单总金额
                OrderSummaryView(cartManager: _cartManager)
                    .padding(.horizontal, geometry.size.width * 0.2)
                
                // 备注输入框
                CommentTextFieldView(commentText: $commentText, isEditing: $isEditing)
                
                // 支付方式选择视图
                PaymentOptionsView(selectedPaymentMethod: $selectedPaymentMethod)
                
                Spacer()
                
                // 打印小票切换按钮
                ReceiptToggleView(printReciept: $printReciept)
                    .padding(.horizontal, geometry.size.width * 0.15)
                
                // 提交按钮
                SubmitButton(cartManager: _cartManager, selectedPaymentMethod: $selectedPaymentMethod, isShowingAlert: $isShowingAlert, alertState: $alertState, alertTitle: $alertTitle, alertContent: $alertContent)
                    .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(.operationListBackground)
            .alert(alertTitle, isPresented: $isShowingAlert) {
                switch alertState {
                case .EmptyList:
                    // 提示还未选择任何商品
                    Button("确认") {
                        isShowingAlert = false
                    }
                case .ConfirmPaymentAlert:
                    // 选择电子货币和现金支付弹出弹窗
                    Button("取消") {
                        isShowingAlert = false
                    }
                    Button("确认") {
                        // 发送订单列表
                        let orderRequest = OrderRequest(
                            paymentMethod: selectedPaymentMethod.rawValue,
                            cartList: cartManager.items,
                            comments: commentText,
                            printReceipt: printReciept
                        )
                        sendRequest(urlString: NSLocalizedString("takeOrder", comment: "URL for taking an order"), requestBody: orderRequest) { result in
                            switch result {
                            case .success(let message):
                                print("Success: \(message)")
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        clearOrderList()
                        isShowingAlert = false
                    }
                case .LoginAlert:
                    // 选择登月通行证支付
                    TextField("手机号码", text: $accountID)
                        .keyboardType(.asciiCapableNumberPad)
                        .onChange(of: accountID) { oldValue, newValue in
                            accountID = phoneNumFormatter(phoneNum: newValue)
                        }
                    Button("取消") {
                        clearLoginState()
                        isShowingAlert = false
                    }
                    Button("刷登月通行证") {
                        let orderRequest = OrderRequest(
                            paymentMethod: selectedPaymentMethod.rawValue,
                            cartList: cartManager.items,
                            comments: commentText,
                            printReceipt: printReciept
                        )
                        sendRequest(urlString: NSLocalizedString("scanCard", comment: "URL for taking an order via scanning card"), requestBody: orderRequest) { result in
                            switch result {
                            case .success(let message):
                                print("Scan Card Success: \(message)")
                                userCardInfoParser.updateCardInfo(message)
                                print(userCardInfoParser.cardInfoDetails.username)
                            case .failure(let error):
                                print("Scan Card Error: \(error.localizedDescription)")
                                userCardInfoParser.updateCardInfo(error.localizedDescription)
                                print(userCardInfoParser.cardInfoDetails.username)
                            }
                        }
                        isShowingAlert = false
                        isShowingLoginSheet = true
                    }
                    Button("提交") {
                        let loginRequest = LoginRequest(
                            paymentMethod: selectedPaymentMethod.rawValue,
                            cartList: cartManager.items,
                            comments: commentText,
                            printReceipt: printReciept,
                            username: accountID
                        )
                        sendRequest(urlString: NSLocalizedString("takeOrderlogin", comment: "URL for taking an order via account login"), requestBody: loginRequest) { result in
                            switch result {
                            case .success(let message):
                                print("Account Login Success: \(message)")
                                userCardInfoParser.updateCardInfo(message)
                                print(userCardInfoParser.cardInfoDetails.username)
                            case .failure(let error):
                                print("Account Login Error: \(error.localizedDescription)")
                                userCardInfoParser.updateCardInfo(error.localizedDescription)
                                print(userCardInfoParser.cardInfoDetails.username)
                            }
                        }
                        clearLoginState()
                        isShowingAlert = false
                        isShowingLoginSheet = true
                    }
                    .disabled(accountID.count != 11)
                }
            } message: {
                Text(alertContent)
            }
            .sheet(isPresented: $isShowingLoginSheet, onDismiss: clearOrderList)  {
                if !userCardInfoParser.receivedString.isEmpty {
                    Text(userCardInfoParser.receivedString)
                } else {
                    // 显示用户卡信息
                    userCardInfoView()
                }
            }
            .onTapGesture { dismissKeyboard() }
        }
    }
    
    /// 显示用户卡信息视图，允许用户输入账号密码或使用 NFC 刷卡
    @ViewBuilder
    private func userCardInfoView() -> some View {
        VStack {
            NavigationStack {
                List {
                    // 用户姓名
                    userInfoSection()
                    // 账户余额
                    originalBalanceSection()
                    
                    if !userCardInfoParser.cardInfoDetails.cupDetails.isEmpty {
                        consumptionSection(
                            title: "使用杯数消费的商品",
                            details: userCardInfoParser.cardInfoDetails.cupDetails
                        )
                    }
                    
                    if !userCardInfoParser.cardInfoDetails.pointDetails.isEmpty {
                        consumptionSection(
                            title: "使用点数消费的商品",
                            details: userCardInfoParser.cardInfoDetails.pointDetails
                        )
                    }
                    
                    newBalanceSection()
                }
                .navigationTitle("登月通行证信息")
            }
        }
    }
    
    /// 用户卡信息视图 用户名称部分
    @ViewBuilder
    private func userInfoSection() -> some View {
        Section {
            Label(
                title: { Text(userCardInfoParser.cardInfoDetails.username) },
                icon: { Image(systemName: "person.circle") }
            )
        } header: {
            Text("用户名称")
        }
    }

    /// 用户卡信息视图 原始余额部分
    @ViewBuilder
    private func originalBalanceSection() -> some View {
        Section {
            Label(
                title: { Text("杯数 \(userCardInfoParser.cardInfoDetails.cupAmount)") },
                icon: { Image(systemName: "cup.and.saucer") }
            )
            Label(
                title: { Text("点数 \(userCardInfoParser.cardInfoDetails.pointAmount)") },
                icon: { Image(systemName: "chineseyuanrenminbisign.circle") }
            )
        } header: {
            Text("登月通行证原余额")
        }
    }

    /// 用户卡信息视图 消费商品部分
    @ViewBuilder
    private func consumptionSection(title: String, details: [ItemDetail]) -> some View {
        Section {
            ForEach(details) { detail in
                HStack {
                    Text(detail.name)
                        .bold()
                    Spacer()
                    Text("\(detail.quantity)")
                }
            }
        } header: {
            Text(title)
        }
    }

    /// 用户卡信息视图 新余额部分
    @ViewBuilder
    private func newBalanceSection() -> some View {
        Section {
            Label(
                title: { Text("杯数 \(userCardInfoParser.cardInfoDetails.cupAmountNew)") },
                icon: { Image(systemName: "cup.and.saucer") }
            )
            .foregroundStyle(
                userCardInfoParser.cardInfoDetails.cupAmountNew != userCardInfoParser.cardInfoDetails.cupAmount ? .red : .primary
            )
            Label(
                title: { Text("点数 \(userCardInfoParser.cardInfoDetails.pointAmountNew)") },
                icon: { Image(systemName: "chineseyuanrenminbisign.circle") }
            )
            .foregroundStyle(
                userCardInfoParser.cardInfoDetails.pointAmountNew != userCardInfoParser.cardInfoDetails.pointAmount ? .red : .primary
            )
        } header: {
            Text("新的余额")
        } footer: {
            Text("已自动为您提供最优惠的消费方案")
        }
    }

    
    /// 清空订单列表和备注
    private func clearOrderList() {
        withAnimation {
            cartManager.items.removeAll()
            commentText = ""
        }
    }
    
    /// 重置账号密码输入状态
    private func clearLoginState() {
        accountID = ""
        isEditing = false
    }
    
    /// 隐藏键盘
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// 订单详情的头部视图，显示标题和清空购物车按钮
struct HeaderView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        ZStack(alignment: .center) {
            Text("订单详情")
                .foregroundStyle(.white)
                .font(.title)
                .bold()
            HStack {
                Spacer()
                Button {
                    cartManager.items.removeAll()
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

/// 显示订单总金额和备注输入框
struct OrderSummaryView: View {
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack {
            // 显示订单的总金额
            HStack {
                Text("总金额:")
                Spacer()
                Text("\(cartManager.totalPrice)")
            }
            .font(.title2)
            .bold()
            .foregroundStyle(.white)
        }
    }
}


/// 备注输入框
struct CommentTextFieldView: View {
    @Binding var commentText: String
    @Binding var isEditing: Bool
    
    var body: some View {
        // 备注输入框，带有占位符
        TextField("", text: $commentText, onCommit: { isEditing = false })
            .textFieldStyle(CommentTextFieldStyle(isEditing: isEditing))
            .padding()
            .placeholder(when: commentText.isEmpty) {
                Text("备注").foregroundColor(.white)
            }
    }
    
}


/// 支付方式选择视图，使用 `Picker` 提供多个支付选项
struct PaymentOptionsView: View {
    @Binding var selectedPaymentMethod: PaymentMethod
    
    var body: some View {
        HStack {
            ForEach(PaymentMethod.allCases) { method in
                Button(action: {
                    selectedPaymentMethod = method
                }) {
                    HStack {
                        Image(systemName: method == selectedPaymentMethod ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(method == selectedPaymentMethod ? .white : .gray)
                        Text(method.rawValue)
                            .foregroundColor(method == selectedPaymentMethod ? .white : .white.opacity(0.7))
                            .font(.headline)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(method == selectedPaymentMethod ? Color.white.opacity(0.5) : Color.white.opacity(0.1))
                    )
                }
                .buttonStyle(.plain) // 移除按钮的默认效果
            }
        }
    }
}


/// 打印小票切换视图，使用 `Toggle` 切换是否打印小票
struct ReceiptToggleView: View {
    @Binding var printReciept: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: $printReciept) {
                Text("打印小票")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .toggleStyle(SwitchToggleStyle(tint: .gray))
        }
    }
}


/// 提交按钮视图，根据选择的支付方式展示不同的提示或登录界面
struct SubmitButton: View {
    @EnvironmentObject var cartManager: CartManager
    @Binding var selectedPaymentMethod: PaymentMethod
    @Binding var isShowingAlert: Bool
    @Binding var alertState: AlertState
    @Binding var alertTitle: String
    @Binding var alertContent: String
    
    var body: some View {
        Button(action: submitOrder) {
            Text("提交")
                .frame(width: UIScreen.main.bounds.width * 0.23)
                .padding(.vertical, 10)
                .font(.title2)
                .bold()
                .foregroundStyle(.white)
                .background(.orange, in: RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        }
    }
    
    /// 提交订单并显示相应的提示信息
    private func submitOrder() {
        if cartManager.items.isEmpty {
            showAlert(title: "还没选择商品", content: "请在商品列表中选取商品后再提交订单!", state: .EmptyList)
        } else {
            switch selectedPaymentMethod {
            case .现金, .电子货币:
                showAlert(title: "请确认支付", content: "请确认用户已通过\(selectedPaymentMethod.rawValue)支付\(cartManager.totalPrice)元", state: .ConfirmPaymentAlert)
            default:
                showAlert(title: "账号密码登录", content: "", state: .LoginAlert)
            }
        }
    }
    
    /// 显示提示信息
    private func showAlert(title: String, content: String, state: AlertState) {
        alertTitle = title
        alertContent = content
        alertState = state
        isShowingAlert = true
    }
}


/// 订单详情列表
struct CartList: View {
    @ObservedObject var cartManager: CartManager
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(cartManager.items) { item in
                    CartListItem(cartItem: item, cartManager: cartManager)
                        .padding(.vertical, 5)
                }
            }
        }
    }
}


/// 订单详情列表中的每一行
struct CartListItem: View {
    @ObservedObject var cartItem: CartItem
    var cartManager: CartManager
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(cartItem.name)
                Spacer()
                HStack {
                    Button(action: {
                        cartManager.cartListMinusOperation(cartItem)
                    }, label: {
                        operationButton(sign: "minus")
                    })
                    Text("\(cartItem.quantity)")
                    Button(action: {
                        cartManager.cartListPlusOperation(cartItem)
                    }, label: {
                        operationButton(sign: "plus")
                    })
                }
                .frame(minWidth: 50)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, geometry.size.width * 0.1)
        }
    }
    
    ///订单列表中增加或减少商品数量的按钮
    private func operationButton(sign: String) -> some View {
        Image(systemName: sign)
            .frame(width: 50, height: 20)
            .background(.pickerBackground, in: RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
    }
}



/// 自定义备注TextFieldStyle
struct CommentTextFieldStyle: TextFieldStyle {
    var isEditing: Bool
    var borderColors: [Color] = [
        .white,
        Color(red: 200 / 255.0, green: 200 / 255.0, blue: 200 / 255.0)
    ]
    var accentColor: Color = .white
    var forgroundColor: Color = .white
    
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            .multilineTextAlignment(.leading)
            .accentColor(accentColor)
            .foregroundColor(forgroundColor)
            .font(.headline.weight(.semibold))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(border)
    }
    
    var border: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(
                LinearGradient(
                    gradient: .init(
                        colors: borderColors
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isEditing ? 4 : 2
            )
    }
}


#Preview {
    ContentView()
    //    OperationListView().environmentObject(CartManager())
}
