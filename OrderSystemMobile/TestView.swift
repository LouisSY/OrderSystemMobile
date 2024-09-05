//
//  TestView.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 05/09/2024.
//

import SwiftUI

struct TestView: View {
    @State private var dates: Set<DateComponents> = []

    var body: some View {
        VStack {
            MultiDatePicker("Dates Available", selection: $dates)
                .padding()
        }
        
    }
}

#Preview {
    TestView()
}
