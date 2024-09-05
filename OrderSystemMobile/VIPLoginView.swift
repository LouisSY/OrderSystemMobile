//
//  VIPLoginView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 29/08/2024.
//

import SwiftUI

/// The title of View, can be used for login.
///
/// If user has not logged in, show login button.
/// If user has looged in, show greeting text.
struct VIPLoginView: View {
    /// name of cardholder
    @Binding var username: String
    /// `phoneNum` of cardholder
    @Binding var phoneNum: String

    @Binding var starAmount: String
    @Binding var moonAmount: String
    
    @State private var isLoading: Bool = false
    
    @State private var isShowingDialog: Bool = false
    @State private var isShowingAlert: Bool = false
    
    @State private var isShowingSheet: Bool = false
    
    @State private var alertTitle: String = "请输入账户信息"
    @State private var alertMessage: String = ""
    
    var body: some View {
        Group {
            if username.isEmpty {
                // show login text
                loginText
            } else {
                
                ZStack {
                    // show greeting text
                    greetingText
                    // show logout button
                    HStack {
                        Spacer()
                        logoutButton
                    }
                }
                
            }
        }
        .padding()
        .sheet(isPresented: $isShowingSheet, content: {
            ScanCardSheetView()
                .interactiveDismissDisabled()
        })
        .alert(alertTitle, isPresented: $isShowingAlert) {
            if alertMessage.isEmpty {
                loginAlert
            } else {
                errorAlert
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    
    @ViewBuilder
    private var loginText: some View {
        HStack {
            Text("登月通行证用户")
            Button {
                isShowingDialog = true
            } label: {
                if !isLoading {
                    // show login button
                    Text("请登录")
                        .underline()
                        .foregroundStyle(.blue)
                        .confirmationDialog("请选择登录方式", isPresented: $isShowingDialog) {
                            confirmationDialog
                        }
                } else {
                    // show loading view when waiting for response of http request
                    ProgressView()
                        .scaleEffect(CGSize(width: 3.0, height: 3.0))
                        .frame(width: 120)
                }
            }
        }
        .font(.system(size: 50))
        .bold()
    }
    
    @ViewBuilder
    private var greetingText: some View {
        HStack {
            Text("您好，")
            Text(username)
                .foregroundStyle(.blue)
            Text("！")
        }
        .font(.system(size: 50))
        .bold()
    }
    
    @ViewBuilder
    private var logoutButton: some View {
        Button {
            withAnimation {
                username.removeAll()
            }
            phoneNum.removeAll()
            starAmount.removeAll()
            moonAmount.removeAll()
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.largeTitle)
                .padding(.horizontal, 50)
        }

    }
    
    @ViewBuilder
    /// select login method: use account information or scan card
    private var confirmationDialog: some View {
        Button("输入账户密码") {
            alertTitle = "请输入账户信息"
            alertMessage = ""
            isShowingDialog = true
            isShowingAlert = true
        }
        Button("刷登月通行证") {
            isShowingSheet = true
            sendLoginScanCardRequest()
        }
    }
    
    @ViewBuilder
    /// Alert used to input account information
    private var loginAlert: some View {
        PhoneNumTextField(phoneNum: $phoneNum)
        
        Button("取消", role: .cancel) {
            isShowingAlert = false
            clearInputs()
        }
        
        Button("提交") {
            withAnimation(.snappy) {
                isLoading = true
            }
            isShowingAlert = false
            let loginRequest = CardInfoRequest(username: phoneNum)
            sendRequest(urlString: NSLocalizedString("accountLogin", comment: "URL for login"), requestBody: loginRequest) { result in
                switch result {
                case .success(let message):
                    print("Login Success: \(message)")
                    assignAccountInfo(jsonString: message)
                    isLoading = false
                case .failure(let error):
                    print("Login Error: \(error.localizedDescription)")
                    alertTitle = "出现问题"
                    alertMessage = error.localizedDescription
                    isShowingAlert = true
                    isLoading = false
                }
            }
        }
    }
    
    @ViewBuilder
    /// Error Alert is used to display error message
    private var errorAlert: some View {
        Button("确认") {
            isShowingAlert = false
        }
    }
    
    /// Transfer `jsonString` to struct and assgin these data to View
    /// - Parameter jsonString: json string of account information
    private func assignAccountInfo(jsonString: String) {
        if let jsonData = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let account = try decoder.decode(AccountInfo.self, from: jsonData)
                withAnimation {
                    username = account.name
                    phoneNum = account.phoneNum
                    starAmount = account.starAmount
                    moonAmount = account.moonAmount
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
    }
    
    /// Remove the inputs of `phoneNum`
    private func clearInputs() {
        phoneNum.removeAll()
    }
    
    /// send login via scanning card request
    private func sendLoginScanCardRequest() {
        sendRequest(urlString: NSLocalizedString("scanBalance", comment: "URL for checking balance via scanning card"), requestBody: "") { result in
            switch result {
            case .success(let message):
                assignAccountInfo(jsonString: message)
                isShowingSheet = false
                print("Login via Scanning Card Success: \(message)")
            case .failure(let error):
                alertTitle = "出现问题"
                alertMessage = error.localizedDescription
                isShowingAlert = true
                print("Login via Scanning Card Error: \(error.localizedDescription)")
            }
        }
    }
}

/// TextField for phone number. Formatter has been applied.
struct PhoneNumTextField: View {
    @Binding var phoneNum: String
    
    var body: some View {
        TextField("手机号码", text: $phoneNum)
            .keyboardType(.asciiCapableNumberPad)
            .onChange(of: phoneNum) { oldValue, newValue in
                phoneNum = phoneNumFormatter(phoneNum: newValue)
            }
    }
}



#Preview {
    VIPLoginView(username: .constant(""), phoneNum: .constant(""), starAmount: .constant(""), moonAmount: .constant(""))
}
