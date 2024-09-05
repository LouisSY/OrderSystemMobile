//
//  AccountInfoView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 29/08/2024.
//

import SwiftUI

/// Display account details
struct AccountInfoView: View {
    @Binding var username: String
    @Binding var starAmount: String
    @Binding var moonAmount: String
    @Binding var phoneNum: String
    
    var body: some View {
 
        VStack(spacing: 30) {
            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                .symbolVariant(.circle.fill)
                .padding()
                .font(.system(size: 100))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .blue.opacity(0.3))
                .padding()
                .background(Circle().fill(.ultraThinMaterial))
                .shadow(radius: 50)
            
            VStack(alignment: .leading) {
                detailText(title: "持卡人\t", content: username)
                detailText(title: "手机号码", content: phoneNum)
                detailText(title: "储值余额", content: starAmount, titleColor: .orange)
                detailText(title: "储杯余额", content: moonAmount, titleColor: .orange)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 50)
        .background(.ultraThinMaterial)
        .background(AngularGradient(colors: [.gray.opacity(0.5), .gray, .gray.opacity(0.5), .gray, .gray.opacity(0.5), .gray, .gray.opacity(0.5)], center: .center))
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .shadow(radius: 100)
        .padding()
    }
    
    @ViewBuilder
    /// Display card info, including each title and corresponding content
    /// - Parameters:
    ///   - title: the title of the content
    ///   - content: information
    ///   - titleColor: the color of the title, defualt is `cyan`
    /// - Returns: view
    private func detailText(title: String, content: String, titleColor: Color = .cyan) -> some View {
        HStack(spacing: 20) {
            Text(title)
                .font(.title)
                .bold()
                .foregroundStyle(titleColor)
                .blendMode(.difference)
            Text(content)
                .font(.title)
                .bold()
                .foregroundStyle(.black)
        }
        .padding(5)
    }
}


#Preview {
    AccountInfoView(username: .constant("Shuai"), starAmount: .constant("260.0"), moonAmount: .constant("15.0"), phoneNum: .constant("19012312311"))
}
