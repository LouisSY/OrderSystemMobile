//
//  NewCardOperation.swift
//  OrderSystemMobile
//
//  Created by Shuai Yuan on 04/09/2024.
//

import Foundation

enum NewCardOperation: String, CaseIterable, Identifiable {
    case topup, reissue, scanCard
    var id: Self { self }
}
