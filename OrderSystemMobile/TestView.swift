//
//  TestView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/09/2024.
//

import SwiftUI

struct TestView: View {
    @State private var date = Date()

    var body: some View {
        DatePicker(
            "Start Date",
            selection: $date,
            displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
    }
}

#Preview {
    TestView()
}
