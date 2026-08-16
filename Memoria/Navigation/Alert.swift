//
//  Alert.swift
//  Memoria
//
//  Created by Joseph McSorley on 8/9/26.
//

import SwiftUI

struct AlertViewComponents: Hashable, Sendable {
    var title = ""
    var message = ""
    var buttons = [AlertButton(id: 0, title: "Ok")]
}

struct AlertButton: Identifiable, Hashable, Sendable {
    var id: Int
    var title: String
    var role = AlertButtonRole.cancel
}

enum AlertButtonRole {
    case cancel
    case destructive
    
    var role: ButtonRole {
        switch self {
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}
