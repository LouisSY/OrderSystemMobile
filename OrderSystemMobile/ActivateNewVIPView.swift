//
//  ActivateNewVIPView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 01/09/2024.
//

import SwiftUI

enum SheetContent {
    case registerForm, scanCard
}

// sign up for new user
struct ActivateNewVIPView: View {
    @Binding var username: String
    @Binding var starAmount: String
    @Binding var moonAmount: String
    @Binding var phoneNum: String
    
    @State var usernameText: String = ""
    @State var starAmountText: String = ""
    @State var phoneNumText: String = ""
    @State var selectedPaymentMethod: PaymentMethod = .电子货币
    
    @State var isShowingSheet: Bool = false
    @State var isScaningCard: Bool = false
    @State var isEditing: Bool = false
    
    @State var isShowingAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    
    var body: some View {
        Button {
            isShowingSheet = true
        } label: {
            Text("办理新用户")
                .font(.title)
                .bold()
                .padding()
        }
        .sheet(isPresented: $isShowingSheet, onDismiss: { isScaningCard = false }, content: {
            if isScaningCard {
                ScanCardSheetView()
                    .interactiveDismissDisabled(isScaningCard)
            } else {
                signupSheet
                    .padding()
            }
        })
        .alert(alertTitle, isPresented: $isShowingAlert) {
            Button("确定") {
                isShowingAlert = false
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    @ViewBuilder
    private var signupSheet: some View {
        Text("注册新用户")
            .font(.system(size: 50))
            .bold()
            .foregroundStyle(
                LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        
        infoTextField(placeholderText: "姓名", bindingText: $usernameText)
        
        infoTextField(placeholderText: "手机号码", bindingText: $phoneNumText)
            .onChange(of: phoneNumText) { oldValue, newValue in
                phoneNumText = phoneNumFormatter(phoneNum: newValue)
            }

        infoTextField(placeholderText: "储值金额", bindingText: $starAmountText)
            .onChange(of: starAmountText) { oldValue, newValue in
                starAmountText = amountFormatter(oldValue: oldValue, newValue: newValue)
            }
        
        
        paymentMethodSelector
            .padding()
        
        Button {
            withAnimation {
                isScaningCard = true
            }
            sendActivationRequest()
        } label: {
            Text("提交")
                .font(.title)
                .bold()
                .padding()
                .frame(width: 300)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                )
        }
        .disabled(phoneNumText.count != 11 || usernameText.isEmpty || starAmountText.isEmpty)
        .padding()

    }
    
    @ViewBuilder
    private func infoTextField(placeholderText: String, bindingText: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(placeholderText)
                .font(.title3)
                .bold()
            TextField(placeholderText, text: bindingText, onCommit: {
                isEditing = false
            })
            .textFieldStyle(
                CommentTextFieldStyle(
                    isEditing: isEditing,
                    borderColors: [.orange, .red],
                    accentColor: .orange,
                    forgroundColor: .primary
                )
            )
            .shadow(radius: 5)
        }
        .padding(.horizontal)
        .padding(.horizontal)
        .padding(.horizontal)
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
                    .scaleEffect(item == selectedPaymentMethod ? 1.2 : 0.7)
                    .foregroundStyle(item == selectedPaymentMethod ? .red : .gray.opacity(0.5))
                }
            }
        }
    }
    
    private func sendActivationRequest() {
        let newUserRequest = NewUserRequest(
            name: usernameText,
            username: phoneNumText,
            starAmount: starAmountText,
            moonAmount: "0",
            moonUnitPrice: "",
            paymentMethod: selectedPaymentMethod.rawValue
        )
        sendRequest(urlString: NSLocalizedString("newAccount", comment: "URL for activating new account"), requestBody: newUserRequest) { result in
            switch result {
            case .success(let message):
                print("Topup Success: \(message)")
                alertTitle = "开启新用户成功"
                alertMessage = message
                isShowingAlert = true
                
                username = usernameText
                starAmount = starAmountText
                moonAmount = "0"
                phoneNum = phoneNumText
                
            case .failure(let error):
                print("Topup Error: \(error.localizedDescription)")
                alertTitle = "出现问题"
                alertMessage = error.localizedDescription
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    ActivateNewVIPView(username: .constant(""), starAmount: .constant(""), moonAmount: .constant(""), phoneNum: .constant(""))
}
