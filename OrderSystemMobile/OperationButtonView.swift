//
//  OperationButtonView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 03/09/2024.
//

import SwiftUI

struct OperationButtonView: View {
    @Binding var phoneNum: String
    @Binding var starAmount: String
    
    @State var isShowingSheet: Bool = true
    @State var sheetType: NewCardOperation = .topup
    
    var body: some View {
        VStack {
            operationButton(text: "充值", icon: "creditcard", feature: { sheetType = .topup })
            operationButton(text: "补办", icon: "person.crop.rectangle.stack", feature: { sheetType = .reissue })
        }
        .sheet(isPresented: $isShowingSheet, content: {
            OperationSheet(
                phoneNum: $phoneNum,
                starAmount: $starAmount,
                isShowingSheet: $isShowingSheet,
                sheetType: $sheetType
            )
            .interactiveDismissDisabled()
        })
    }
    
    @ViewBuilder
    private func operationButton(text: String, icon: String, feature: @escaping () -> Void) -> some View {
        Button {
            feature()
            isShowingSheet = true
        } label: {
            HStack(spacing: 20) {
                Image(systemName: icon)
                Text(text)
            }
            .font(.system(size: 40))
            .bold()
            .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
            .padding(.horizontal, 150)
            .padding(.vertical, 50)
            .background(.ultraThinMaterial)
            .background(LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .shadow(radius: 10)
            .padding()
        }
    }
}

struct OperationSheet: View {
    @Binding var phoneNum: String
    @Binding var starAmount: String
    @Binding var isShowingSheet: Bool
    @Binding var sheetType: NewCardOperation
    
    @State var isShowingAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    
    @State private var isEditing: Bool = false
    
    @State private var starAmountText: String = ""
    @State private var giftAmountText: String = ""
    @State private var selectedPaymentMethod: PaymentMethod = .电子货币
    
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        Group {
            switch sheetType {
            case .topup:
                topupSheet
            case .reissue:
                resissueSheet
            case .scanCard:
                ScanCardSheetView()
            }
        }
        .alert(alertTitle, isPresented: $isShowingAlert) {
            Button {
                isShowingAlert = false
                isShowingSheet = false
            } label: {
                Text("确认")
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var topupSheet: some View {
        VStack {
            // 页面标题
            viewTitle(title: "充值")
                .offset(x: -200, y: 200)
            
            Spacer()
            
            // 充值金额输入框
            amountTextField(placeholder: "充值金额", icon: "dollarsign.circle", bindingText: $starAmountText)
                .onChange(of: starAmountText) { oldValue, newValue in
                    starAmountText = amountFormatter(oldValue: oldValue, newValue: newValue)
                }
            amountTextField(placeholder: "赠送金额", icon: "gift", bindingText: $giftAmountText)
                .onChange(of: giftAmountText) { oldValue, newValue in
                    giftAmountText = amountFormatter(oldValue: oldValue, newValue: newValue)
                }
            
            // 选取支付方式
            paymentMethodSelector
                .padding()
            
            sheetButton(text: "取消", colors: [.gray, .gray]) {
                isShowingSheet = false
            }
            
            sheetButton(text: "确认充值", colors: starAmountText.isEmpty ? [.gray, .gray.opacity(0.7)] : [.cyan, .purple]) {
                sendTopupRequest()
            }
            .padding(.vertical)
            .shadow(radius: 10)
            .padding(.bottom)
            .disabled(starAmountText.isEmpty)
        }
    }
    
    private var resissueSheet: some View {
        VStack {
            // 页面标题
            viewTitle(title: "补办")
                .offset(x: -200, y: 200)
            
            Spacer()
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("补办卡片需要支付15元")
                    .bold()
            }
            .font(.largeTitle)
            
            // 选取支付方式
            paymentMethodSelector
                .padding()
            
            sheetButton(text: "取消", colors: [.gray, .gray]) {
                isShowingSheet = false
            }
            
            sheetButton(text: "确认支付", colors: [.cyan, .purple]) {
                withAnimation(.interactiveSpring) {
                    sheetType = .scanCard
                }
                sendReissueRequest()
            }
            .padding(.vertical)
            .shadow(radius: 10)
            .padding(.bottom)
        }
    }
    
    
    /// 页面标题
    private func viewTitle(title: String) -> some View {
        Text(title)
            .font(.system(size: 70))
            .bold()
            .foregroundStyle(
                LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
            )
            .background(
                BubbleIcon()
                    .offset(x: 300, y: 200)
                    .foregroundStyle(
                        LinearGradient(colors: [.black, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 700, height: 700)
                    .shadow(radius: 10)
            )
    }

    /// 充值金额输入框
    @ViewBuilder
    private func amountTextField(placeholder: String, icon: String, bindingText: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            // 标题
            HStack {
                Image(systemName: icon)
                Text(placeholder)
            }
            .font(.title3)
            .bold()
            
            // 输入框
            TextField(placeholder, text: bindingText, onCommit: {
                isEditing = false
            })
            .textFieldStyle(
                CommentTextFieldStyle(
                    isEditing: isEditing,
                    borderColors: [.cyan, .gray],
                    accentColor: .blue,
                    forgroundColor: .primary
                )
            )
            .shadow(radius: 10)
            .keyboardType(.decimalPad)
        }
        .padding(.horizontal)
        .padding()
    }
    
    /// 选择支付方式
    private var paymentMethodSelector: some View {
        HStack {
            ForEach([PaymentMethod.电子货币, PaymentMethod.现金], id: \.self) { item in
                Button {
                    withAnimation {
                        selectedPaymentMethod = item
                    }
                } label: {
                    VStack {
                        Image(systemName: item.imageName )
                            .font(.title)
                        Text(item.rawValue)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .shadow(radius: item == selectedPaymentMethod ? 10 : 0)
                    .scaleEffect(item == selectedPaymentMethod ? 1 : 0.7)
                    .foregroundStyle(item == selectedPaymentMethod ? .purple : .gray.opacity(0.5))
                }
            }
        }
    }
    
    /// 按钮
    private func sheetButton(text: String, colors: [Color], feature: @escaping () -> Void) -> some View {
        Button {
            feature()
        } label: {
            Text(text)
                .font(.title)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                )
                .padding(.horizontal)
                .padding(.horizontal)
        }
    }
    
    /// 计算新的金额
    private var calculateNewAmount: String {
        if starAmountText.isEmpty {
            return "--"
        } else {
            return String(describing: Decimal(Double(starAmount) ?? 0) + Decimal(Double(starAmountText) ?? 0))
        }
    }
    
    /// 发起topup请求
    private func sendTopupRequest() {
        let topupRequest = TopUpRequest(
            username: phoneNum,
            starAmount: starAmountText,
            giftAmount: "",
            paymentMethod: selectedPaymentMethod.rawValue
        )
        sendRequest(urlString: NSLocalizedString("topup", comment: "URL for topup"), requestBody: topupRequest) { result in
            // Handle the request result
            switch result {
            case .success(let message):
                print("Topup Success: \(message)")
                alertTitle = "充值成功"
                alertMessage = message
                isShowingAlert = true
                starAmount = calculateNewAmount
            case .failure(let error):
                print("Topup Error: \(error.localizedDescription)")
                alertTitle = "出现问题"
                alertMessage = error.localizedDescription
                isShowingAlert = true
            }
        }
    }
    
    private func sendReissueRequest() {
        let reissueRequest = ReissueRequest(
            username: phoneNum,
            paymentMethod: selectedPaymentMethod.rawValue
        )
        sendRequest(urlString: NSLocalizedString("reissue", comment: "URL for reissue"), requestBody: reissueRequest) { result in
            switch result {
            case .success(let message):
                alertTitle = "补办成功"
                alertMessage = message
                isShowingAlert = true
                print("Reissue Success: \(message)")
            case .failure(let error):
                alertTitle = "出现问题"
                alertMessage = error.localizedDescription
                isShowingAlert = true
                print("Reissue Error: \(error.localizedDescription)")
            }
        }
    }
}


struct ScanCardSheetView: View {
    @State private var symbolEffect: Bool = false
    
    var body: some View {
        Image(systemName: "antenna.radiowaves.left.and.right")
            .font(.system(size: 300))
            .symbolEffect(.variableColor, options: .repeating, value: symbolEffect)
            .onAppear {
                symbolEffect = true
            }
            .onDisappear {
                symbolEffect = false
            }
        Text("请将登月通行证置于读卡器上")
            .font(.largeTitle)
            .bold()
    }
}



#Preview {
    OperationButtonView(phoneNum: .constant("19031977559"), starAmount: .constant("100"))
}
