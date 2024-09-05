//
//  NewVIPView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 29/08/2024.
//

import SwiftUI

struct NewVIPView: View {
    @State var username: String = ""
    @State var starAmount: String = ""
    @State var moonAmount: String = ""
    @State var phoneNum: String = ""
    
    
    var body: some View {
        VStack {
            VIPLoginView(username: $username, phoneNum: $phoneNum, starAmount: $starAmount, moonAmount: $moonAmount)
            
            if !username.isEmpty {
                HStack {
                    AccountInfoView(username: $username, starAmount: $starAmount, moonAmount: $moonAmount, phoneNum: $phoneNum)
                        .frame(maxWidth: .infinity)
                    
                    OperationButtonView(
                        phoneNum: $phoneNum, starAmount: $starAmount
                    )
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
                
            } else {
                ActivateNewVIPView(username: $username, starAmount: $starAmount, moonAmount: $moonAmount, phoneNum: $phoneNum)
            }
        }
    }
}



#Preview {
    NewVIPView()
}
