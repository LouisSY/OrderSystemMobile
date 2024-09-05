//
//  ToolBarView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/06/2024.
//

import SwiftUI

struct ToolBarView: View {
    @Binding var viewGroup: ViewGroup
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                    .frame(height: geometry.size.width * 0.1)
                ButtonIcon(text: "主页", sfSymbolName: "house", viewGroup: $viewGroup)
                ButtonIcon(text: "订单", sfSymbolName: "doc.text", viewGroup: $viewGroup)
                ButtonIcon(text: "VIP", sfSymbolName: "crown", viewGroup: $viewGroup)
                ButtonIcon(text: "统计", sfSymbolName: "doc.text", viewGroup: $viewGroup)
                ButtonIcon(text: "修改", sfSymbolName: "pencil.tip.crop.circle", viewGroup: $viewGroup)
                ButtonIcon(text: "菜单", sfSymbolName: "square.and.arrow.up.on.square", viewGroup: $viewGroup)
                Spacer()
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .background(.black)
        }
    }
}

struct ButtonIcon: View {
    var text: String
    var sfSymbolName: String
    @Binding var viewGroup: ViewGroup
    
    var body: some View {
        Button(action: {
            viewGroup = ViewGroup(rawValue: text) ?? .主页
        }, label: {
            VStack {
                Image(systemName: viewGroup.rawValue == text ? sfSymbolName + ".fill" : sfSymbolName)
                Text(text)
                    .font(.caption)
                    .bold()
            }
        })
        .foregroundStyle(viewGroup.rawValue == text ? .white : .gray)
    }
}

#Preview {
    ToolBarView(viewGroup: .constant(.主页))
}
